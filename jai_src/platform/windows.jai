
Windows_Specific_Data :: struct {
    next_hotkey_id: int = 0;
}

platform_init_windows :: (ctx: *System_Hotkey_Context) {
    // table_init not needed
}

platform_shutdown_windows :: (ctx: *System_Hotkey_Context) {
    // Ungrab all keys
    for id, key: ctx.hotkey_map {
        UnregisterHotKey(null, id);
    }
    table_reset(*ctx.hotkey_map);
    table_reset(*ctx.hotkey_id_to_callback_map);
    table_reset(*ctx.hotkey_id_to_user_data_map);
}

platform_register_hotkey_windows :: (ctx: *System_Hotkey_Context, hotkey: Hotkey, callback: Hotkey_Callback, user_data: *void) -> bool {
    
    modifiers := to_windows_modifiers(hotkey.modifiers);
    vk := get_platform_keycode(hotkey.key);
    if vk == 0 {
        log_error("Invalid key: %", hotkey.key);
        return false;
    }

    id := ctx.windows_data.next_hotkey_id;
    ctx.windows_data.next_hotkey_id += 1;

    if !RegisterHotKey(null, id, modifiers, vk) {
        log_error("Failed to register hotkey.");
        return false;
    }

    table_add(*ctx.hotkey_map, hotkey, id);
    table_add(*ctx.hotkey_id_to_callback_map, id, callback);
    table_add(*ctx.hotkey_id_to_user_data_map, id, user_data);

    return true;
}

platform_unregister_hotkey_windows :: (ctx: *System_Hotkey_Context, hotkey: Hotkey) -> bool {
    
    found, id := table_find(*ctx.hotkey_map, hotkey);
    if !found {
        log_error("Hotkey not registered.");
        return false;
    }

    if !UnregisterHotKey(null, id) {
        log_error("Failed to unregister hotkey.");
        return false;
    }
    
    table_remove(*ctx.hotkey_map, hotkey);
    table_remove(*ctx.hotkey_id_to_callback_map, id);
    table_remove(*ctx.hotkey_id_to_user_data_map, id);

    return true;
}

platform_poll_events_windows :: (ctx: *System_Hotkey_Context) {
    msg: MSG;
    while PeekMessageA(*msg, null, 0, 0, PM_REMOVE) {
        if msg.message == WM_HOTKEY {
            
            hotkey_id := msg.wParam;
            
            found, callback := table_find(*ctx.hotkey_id_to_callback_map, hotkey_id);
            if found {
                
                found_ud, user_data := table_find(*ctx.hotkey_id_to_user_data_map, hotkey_id);

                // We need to find the hotkey associated with this id.
                for id, key: ctx.hotkey_map {
                    if id == hotkey_id {
                        callback(key, user_data);
                        break;
                    }
                }
            }
        } else {
            TranslateMessage(*msg);
            DispatchMessageA(*msg);
        }
    }
}

to_windows_modifiers :: (mods: Hotkey_Modifier) -> u32 {
    result: u32 = 0;
    if mods & .ALT      result |= MOD_ALT;
    if mods & .CONTROL  result |= MOD_CONTROL;
    if mods & .SHIFT    result |= MOD_SHIFT;
    if mods & .SUPER    result |= MOD_WIN;
    return result;
}
