// ffi.jai

#import "Basic";

// C-compatible structs
C_Hotkey :: struct {
    modifiers: u32;
    key: u32;
}

// Foreign function declarations
// (Removed incorrect #foreign block)


//
// Implementation of the foreign functions
//

system_hotkey_init :: () -> *System_Hotkey_Context {
    return init();
}

system_hotkey_shutdown :: (ctx: *System_Hotkey_Context) {
    shutdown(ctx);
}

ffi_callback :: (hotkey: Hotkey, user_data: *void) {
    ctx := cast(*System_Hotkey_Context) user_data;
    array_add(*ctx.triggered_hotkeys, hotkey);
}

system_hotkey_register :: (ctx: *System_Hotkey_Context, c_hotkey: C_Hotkey) -> bool {
    hotkey: Hotkey;
    hotkey.modifiers = cast(Hotkey_Modifier) c_hotkey.modifiers;
    hotkey.key = cast(Key) c_hotkey.key;

    return register_hotkey(ctx, hotkey, ffi_callback, ctx);
}

system_hotkey_unregister :: (ctx: *System_Hotkey_Context, c_hotkey: C_Hotkey) -> bool {
    hotkey: Hotkey;
    hotkey.modifiers = cast(Hotkey_Modifier) c_hotkey.modifiers;
    hotkey.key = cast(Key) c_hotkey.key;
    return unregister_hotkey(ctx, hotkey);
}

system_hotkey_poll_events :: (ctx: *System_Hotkey_Context) {
    poll_events(ctx);
}

system_hotkey_get_triggered_hotkeys :: (ctx: *System_Hotkey_Context) -> []C_Hotkey {
    result: [..]C_Hotkey;
    for ctx.triggered_hotkeys {
        c_hotkey: C_Hotkey;
        c_hotkey.modifiers = cast(u32) it.modifiers;
        c_hotkey.key = cast(u32) it.key;
        array_add(*result, c_hotkey);
    }
    array_reset(*ctx.triggered_hotkeys);
    return result;
}