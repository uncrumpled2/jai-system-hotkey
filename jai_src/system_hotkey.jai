// jai_src/system_hotkey.jai

#import "Basic";
#import "Hash_Table"; // Moved to global scope

#load "log.jai";
#load "keycodes.jai";
#load "ffi.jai";
#load "enums.jai";

#if OS == .LINUX {
    #import "X11";
    #load "platform/linux.jai";
}
#if OS == .WINDOWS {
    #import "Windows";
    #load "platform/windows.jai";
}
#if OS == .MACOS {
    #import "Carbon";
    #load "platform/macos.jai";
}

//
// Enums and Structs
//

Hotkey :: struct {
    modifiers: Hotkey_Modifier;
    key: Key;
}

hash_hotkey :: (k: Hotkey) -> u32 {
    h := cast(u32) k.modifiers;
    h = (h << 5) + h + cast(u32) k.key;
    return h;
}

compare_hotkeys :: (a: Hotkey, b: Hotkey) -> bool {
    return a.modifiers == b.modifiers && a.key == b.key;
}

Hotkey_Callback :: #type (hotkey: Hotkey, user_data: *void);

System_Hotkey_Context :: struct {
    triggered_hotkeys: [..]Hotkey;
    verbose: bool;

    // Platform-specific data will go here
    #if OS == .WINDOWS {
        windows_data: Windows_Specific_Data;
        hotkey_map: Table(Hotkey, s32, hash_hotkey, compare_hotkeys);
        hotkey_id_to_callback_map: Table(s32, Hotkey_Callback);
        hotkey_id_to_user_data_map: Table(s32, *void);
    }
    #if OS == .LINUX {
        linux_data: Linux_Specific_Data;
        hotkey_map: Table(Hotkey, Hotkey_Callback, hash_hotkey, compare_hotkeys);
        hotkey_to_user_data_map: Table(Hotkey, *void, hash_hotkey, compare_hotkeys);
    }
    #if OS == .MACOS {
        macos_data: MacOS_Specific_Data;
        hotkey_map: Table(Hotkey, EventHotKeyRef, hash_hotkey, compare_hotkeys);
        hotkey_ref_to_callback_map: Table(EventHotKeyRef, Hotkey_Callback);
        hotkey_ref_to_user_data_map: Table(EventHotKeyRef, *void);
    }
    #if OS != .WINDOWS && OS != .LINUX && OS != .MACOS {
        // A dummy map so the code compiles on unsupported OSes
        hotkey_map: Table(Hotkey, Hotkey_Callback, hash_hotkey, compare_hotkeys);
        hotkey_to_user_data_map: Table(Hotkey, *void, hash_hotkey, compare_hotkeys);
    }
}

//
// Public API
//

init :: (verbose: bool = false) -> *System_Hotkey_Context {
    init_key_map();
    ctx := New(System_Hotkey_Context);
    ctx.verbose = verbose;
    // array_init(*ctx.triggered_hotkeys); // Not needed for dynamic arrays
    
    #if OS == .WINDOWS {
        platform_init_windows(ctx);
    }
    #if OS == .LINUX {
        platform_init_linux(ctx);
    }
    #if OS == .MACOS {
        platform_init_macos(ctx);
    }
    #if OS != .WINDOWS && OS != .LINUX && OS != .MACOS {
        assert(false, "Unsupported OS");
    }
        
    return ctx;
}

shutdown :: (ctx: *System_Hotkey_Context) {
    #if OS == .WINDOWS {
        platform_shutdown_windows(ctx);
    }
    #if OS == .LINUX {
        platform_shutdown_linux(ctx);
    }
    #if OS == .MACOS {
        platform_shutdown_macos(ctx);
    }
    
    array_free(ctx.triggered_hotkeys);
    free(ctx);
}

register_hotkey :: (ctx: *System_Hotkey_Context, hotkey: Hotkey, callback: Hotkey_Callback, user_data: *void) -> bool {
    // Here, we would add the hotkey and callback to our map.
    // Then, we would call the platform-specific registration function.
    
    #if OS == .WINDOWS {
        return platform_register_hotkey_windows(ctx, hotkey, callback, user_data);
    }
    #if OS == .LINUX {
        return platform_register_hotkey_linux(ctx, hotkey, callback, user_data);
    }
    #if OS == .MACOS {
        return platform_register_hotkey_macos(ctx, hotkey, callback, user_data);
    }
    #if OS != .WINDOWS && OS != .LINUX && OS != .MACOS {
        return false;
    }
}

unregister_hotkey :: (ctx: *System_Hotkey_Context, hotkey: Hotkey) -> bool {
    // Here, we would remove the hotkey from our map.
    // Then, we would call the platform-specific unregistration function.

    #if OS == .WINDOWS {
        return platform_unregister_hotkey_windows(ctx, hotkey);
    }
    #if OS == .LINUX {
        return platform_unregister_hotkey_linux(ctx, hotkey);
    }
    #if OS == .MACOS {
        return platform_unregister_hotkey_macos(ctx, hotkey);
    }
    #if OS != .WINDOWS && OS != .LINUX && OS != .MACOS {
        return false;
    }
}

poll_events :: (ctx: *System_Hotkey_Context) {
    // This function will be called repeatedly by the user to process hotkey events.
    
    #if OS == .WINDOWS {
        platform_poll_events_windows(ctx);
    }
    #if OS == .LINUX {
        platform_poll_events_linux(ctx);
    }
    #if OS == .MACOS {
        platform_poll_events_macos(ctx);
    }
    #if OS != .WINDOWS && OS != .LINUX && OS != .MACOS {
        // Dummy implementation for unsupported OSes
    }
}