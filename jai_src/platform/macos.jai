
MacOS_Specific_Data :: struct {
    next_hotkey_id: int = 0;
}

platform_init_macos :: (ctx: *System_Hotkey_Context) {
    event_types: [2]EventTypeSpec;
    event_types[0].eventClass = kEventClassKeyboard;
    event_types[0].eventKind = kEventHotKeyPressed;
    event_types[1].eventClass = kEventClassKeyboard;
    event_types[1].eventKind = kEventHotKeyReleased;

    InstallApplicationEventHandler(NewEventHandlerUPP(hotkey_handler), 2, *event_types, ctx, null);
}

platform_shutdown_macos :: (ctx: *System_Hotkey_Context) {
    // Ungrab all keys
    for ref, key: ctx.hotkey_map {
        UnregisterEventHotKey(ref);
    }
    table_reset(*ctx.hotkey_map);
    table_reset(*ctx.hotkey_ref_to_callback_map);
    table_reset(*ctx.hotkey_ref_to_user_data_map);
}

platform_register_hotkey_macos :: (ctx: *System_Hotkey_Context, hotkey: Hotkey, callback: Hotkey_Callback, user_data: *void) -> bool {
    
    modifiers := to_macos_modifiers(hotkey.modifiers);
    keycode := get_platform_keycode(hotkey.key);
    if keycode == 0 {
        log_error("Invalid key: %", hotkey.key);
        return false;
    }

    id: EventHotKeyID;
    id.signature = "htk_";
    id.id = ctx.macos_data.next_hotkey_id;
    ctx.macos_data.next_hotkey_id += 1;

    hotkey_ref: EventHotKeyRef;
    if RegisterEventHotKey(keycode, modifiers, id, GetApplicationEventTarget(), 0, *hotkey_ref) != noErr {
        log_error("Failed to register hotkey.");
        return false;
    }

    table_add(*ctx.hotkey_map, hotkey, hotkey_ref);
    table_add(*ctx.hotkey_ref_to_callback_map, hotkey_ref, callback);
    table_add(*ctx.hotkey_ref_to_user_data_map, hotkey_ref, user_data);

    return true;
}

platform_unregister_hotkey_macos :: (ctx: *System_Hotkey_Context, hotkey: Hotkey) -> bool {
    
    found, ref := table_find(*ctx.hotkey_map, hotkey);
    if !found {
        log_error("Hotkey not registered.");
        return false;
    }

    if UnregisterEventHotKey(ref) != noErr {
        log_error("Failed to unregister hotkey.");
        return false;
    }
    
    table_remove(*ctx.hotkey_map, hotkey);
    table_remove(*ctx.hotkey_ref_to_callback_map, ref);
    table_remove(*ctx.hotkey_ref_to_user_data_map, ref);

    return true;
}

platform_poll_events_macos :: (ctx: *System_Hotkey_Context) {
    // Event loop is handled by the OS, but we need to run the event loop
    RunApplicationEventLoop();
}

hotkey_handler :: (handler_call_ref: EventHandlerCallRef, event: EventRef, user_data: *void) -> OSStatus {
    ctx := cast(*System_Hotkey_Context) user_data;
    
    hotkey_id: EventHotKeyID;
    GetEventParameter(event, kEventParamDirectObject, typeEventHotKeyID, null, size_of(EventHotKeyID), null, *hotkey_id);

    // We need to find the hotkey associated with this id.
    // This is not efficient, but it's the only way with the current API.
    for ref, key: ctx.hotkey_map {
        hotkey_ref := cast(*EventHotKeyRef) ref;
        
        id: EventHotKeyID;
        GetEventHotKeyID(hotkey_ref, *id);

        if id.id == hotkey_id.id {
            found, callback := table_find(*ctx.hotkey_ref_to_callback_map, ref);
            if found {
                found_ud, user_data := table_find(*ctx.hotkey_ref_to_user_data_map, ref);
                callback(key, user_data);
            }
            break;
        }
    }
    
    return noErr;
}

to_macos_modifiers :: (mods: Hotkey_Modifier) -> u32 {
    result: u32 = 0;
    if mods & .SHIFT    result |= shiftKey;
    if mods & .CONTROL  result |= controlKey;
    if mods & .ALT      result |= optionKey;
    if mods & .SUPER    result |= cmdKey;
    return result;
}
