// ffi.jai - FFI exports for shared library

#import "Basic";

// C-compatible structs
C_Hotkey :: struct {
    modifiers: u32;
    key: u32;
}

// C-compatible array for returning triggered hotkeys
C_Hotkey_Array :: struct {
    count: s64;
    data: *C_Hotkey;
}

// Static storage for triggered hotkeys (to return to C)
#no_reset triggered_buffer: [64]C_Hotkey;
#no_reset triggered_result: C_Hotkey_Array;

// Internal callback used by FFI
ffi_callback :: (hotkey: Hotkey, user_data: *void) {
    ctx := cast(*System_Hotkey_Context) user_data;
    array_add(*ctx.triggered_hotkeys, hotkey);
}

//
// Exported functions for shared library use
//

#program_export
system_hotkey_init :: () -> *void #c_call {
    ctx: *System_Hotkey_Context;
    push_context {
        ctx = init();
    }
    return ctx;
}

#program_export
system_hotkey_shutdown :: (ctx: *void) #c_call {
    push_context {
        shutdown(cast(*System_Hotkey_Context) ctx);
    }
}

#program_export
system_hotkey_register :: (ctx: *void, c_hotkey: C_Hotkey) -> s32 #c_call {
    result: bool;
    push_context {
        hotkey: Hotkey;
        hotkey.modifiers = cast(Hotkey_Modifier) c_hotkey.modifiers;
        hotkey.key = cast(Key) c_hotkey.key;
        result = register_hotkey(cast(*System_Hotkey_Context) ctx, hotkey, ffi_callback, ctx);
    }
    return cast(s32) result;
}

#program_export
system_hotkey_unregister :: (ctx: *void, c_hotkey: C_Hotkey) -> s32 #c_call {
    result: bool;
    push_context {
        hotkey: Hotkey;
        hotkey.modifiers = cast(Hotkey_Modifier) c_hotkey.modifiers;
        hotkey.key = cast(Key) c_hotkey.key;
        result = unregister_hotkey(cast(*System_Hotkey_Context) ctx, hotkey);
    }
    return cast(s32) result;
}

#program_export
system_hotkey_poll_events :: (ctx: *void) #c_call {
    push_context {
        poll_events(cast(*System_Hotkey_Context) ctx);
    }
}

#program_export
system_hotkey_get_triggered_hotkeys :: (ctx: *void) -> C_Hotkey_Array #c_call {
    push_context {
        shk_ctx := cast(*System_Hotkey_Context) ctx;
        count := min(shk_ctx.triggered_hotkeys.count, 64);

        for i: 0..count-1 {
            triggered_buffer[i].modifiers = cast(u32) shk_ctx.triggered_hotkeys[i].modifiers;
            triggered_buffer[i].key = cast(u32) shk_ctx.triggered_hotkeys[i].key;
        }

        array_reset(*shk_ctx.triggered_hotkeys);

        triggered_result.count = count;
        triggered_result.data = triggered_buffer.data;
    }
    return triggered_result;
}
