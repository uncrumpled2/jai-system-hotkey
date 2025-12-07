#import "Basic"; // For print

Linux_Specific_Data :: struct {
    display: *Display;
    root: Window;
}

num_lock_mask: u32;
XK_Num_Lock :: 0xFF7F;

platform_init_linux :: (ctx: *System_Hotkey_Context) -> bool {
    display := XOpenDisplay(null);
    if !display {
        log_error("Failed to open X display");
        return false;
    }

    ctx.linux_data.display = display;
    ctx.linux_data.root = XDefaultRootWindow(display);

    // Select KeyPress events on the root window to ensure we receive them
    XSelectInput(display, ctx.linux_data.root, KeyPressMask);

    num_lock_mask = find_num_lock_mask(display);
    if ctx.verbose {
        print("System Hotkey: NumLock Mask detected: %\n", num_lock_mask);
    }
    return true;
}

platform_shutdown_linux :: (ctx: *System_Hotkey_Context) {
    // Only clean up if display was opened
    if ctx.linux_data.display != null {
        // Ungrab all keys
        for cb, key: ctx.hotkey_map {
            platform_unregister_hotkey_linux(ctx, key);
        }
        XCloseDisplay(ctx.linux_data.display);
    }
    table_reset(*ctx.hotkey_map);
    table_reset(*ctx.hotkey_to_user_data_map);
}

platform_register_hotkey_linux :: (ctx: *System_Hotkey_Context, hotkey: Hotkey, callback: Hotkey_Callback, user_data: *void) -> bool {
    display := ctx.linux_data.display;
    if display == null {
        log_error("Cannot register hotkey: X display not available");
        return false;
    }
    root := ctx.linux_data.root;

    modifiers := to_x11_modifiers(hotkey.modifiers);
        
    keysym := get_platform_keycode(hotkey.key);
    if keysym == 0 {
        log_error("Invalid key: %", hotkey.key);
        return false;
    }
    
    keycode := XKeysymToKeycode(display, keysym);
    if keycode == 0 {
        log_error("Could not get keycode for key: %", hotkey.key);
        return false;
    }

    if ctx.verbose {
        print("System Hotkey: Registering Keycode: %, Modifiers: %\n", keycode, modifiers);
    }

    // Grab the key with various lock modifiers
    // owner_events = 0 (False) to enforce grab reporting
    XGrabKey(display, keycode, modifiers, root, 0, GrabModeAsync, GrabModeAsync);
    XGrabKey(display, keycode, modifiers | LockMask, root, 0, GrabModeAsync, GrabModeAsync);
    XGrabKey(display, keycode, modifiers | num_lock_mask, root, 0, GrabModeAsync, GrabModeAsync);
    XGrabKey(display, keycode, modifiers | LockMask | num_lock_mask, root, 0, GrabModeAsync, GrabModeAsync);

    // Sync to catch errors immediately
    XSync(display, 0);

    table_add(*ctx.hotkey_map, hotkey, callback);
    table_add(*ctx.hotkey_to_user_data_map, hotkey, user_data);

    return true;
}

platform_unregister_hotkey_linux :: (ctx: *System_Hotkey_Context, hotkey: Hotkey) -> bool {
    display := ctx.linux_data.display;
    root := ctx.linux_data.root;
    
    modifiers := to_x11_modifiers(hotkey.modifiers);
        
    keysym := get_platform_keycode(hotkey.key);
    if keysym == 0 {
        log_error("Invalid key: %", hotkey.key);
        return false;
    }
    
    keycode := XKeysymToKeycode(display, keysym);
    if keycode == 0 {
        log_error("Could not get keycode for key: %", hotkey.key);
        return false;
    }

    XUngrabKey(display, keycode, modifiers, root);
    XUngrabKey(display, keycode, modifiers | LockMask, root);
    XUngrabKey(display, keycode, modifiers | num_lock_mask, root);
    XUngrabKey(display, keycode, modifiers | LockMask | num_lock_mask, root);
    
    table_remove(*ctx.hotkey_map, hotkey);
    table_remove(*ctx.hotkey_to_user_data_map, hotkey);

    XFlush(display);

    return true;
}

platform_poll_events_linux :: (ctx: *System_Hotkey_Context) {
    display := ctx.linux_data.display;
    if display == null return;  // No display available

    while XPending(display) > 0 {
        event: XEvent;
        XNextEvent(display, *event);

        if event.type == KeyPress {
            if ctx.verbose {
                print("System Hotkey: KeyPress received. Keycode: %\n", event.xkey.keycode);
            }
            
            hotkey: Hotkey;
            hotkey.modifiers = from_x11_modifiers(event.xkey.state);
            
            keysym := XLookupKeysym(*event.xkey, 0);
            hotkey.key = from_platform_keycode(cast(u32)keysym);
            
            found, callback := table_find(*ctx.hotkey_map, hotkey);
            if found {
                if ctx.verbose {
                    print("System Hotkey: Match found for key %. Calling callback.\n", hotkey.key);
                }
                found_ud, user_data := table_find(*ctx.hotkey_to_user_data_map, hotkey);
                callback(hotkey, user_data);
            } else {
                if ctx.verbose {
                    print("System Hotkey: No match found for key % (Keysym: %)\n", hotkey.key, keysym);
                }
            }
        }
    }
}

to_x11_modifiers :: (mods: Hotkey_Modifier) -> u32 {
    result: u32 = 0;
    if mods & .SHIFT    result |= ShiftMask;
    if mods & .CONTROL  result |= ControlMask;
    if mods & .ALT      result |= Mod1Mask;
    if mods & .SUPER    result |= Mod4Mask;
    return result;
}

from_x11_modifiers :: (state: u32) -> Hotkey_Modifier {
    result: Hotkey_Modifier = .NONE;
    if state & ShiftMask    result |= .SHIFT;
    if state & ControlMask  result |= .CONTROL;
    if state & Mod1Mask     result |= .ALT;
    if state & Mod4Mask     result |= .SUPER;
    return result;
}

find_num_lock_mask :: (display: *Display) -> u32 {
    modmap := XGetModifierMapping(display);
    if !modmap return 0;
    defer XFreeModifiermap(modmap);

    for i: 0..7 {
        for j: 0..modmap.max_keypermod-1 {
            keycode := modmap.modifiermap[i * modmap.max_keypermod + j];
            if keycode {
                keysym := XKeycodeToKeysym(display, keycode, 0);
                if keysym == XK_Num_Lock {
                    return cast(u32)(1 << i);
                }
            }
        }
    }
    return 0;
}