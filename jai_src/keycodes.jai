// jai_src/keycodes.jai

Key_Code :: struct {
    x11: u32;
    windows: u32;
    macos: u32;
}

key_map: Table(Key, Key_Code);

#if OS != .LINUX {
    XK_a :: 0x0061;
    XK_b :: 0x0062;
    XK_c :: 0x0063;
    XK_d :: 0x0064;
    XK_e :: 0x0065;
    XK_f :: 0x0066;
    XK_g :: 0x0067;
    XK_h :: 0x0068;
    XK_i :: 0x0069;
    XK_j :: 0x006a;
    XK_k :: 0x006b;
    XK_l :: 0x006c;
    XK_m :: 0x006d;
    XK_n :: 0x006e;
    XK_o :: 0x006f;
    XK_p :: 0x0070;
    XK_q :: 0x0071;
    XK_r :: 0x0072;
    XK_s :: 0x0073;
    XK_t :: 0x0074;
    XK_u :: 0x0075;
    XK_v :: 0x0076;
    XK_w :: 0x0077;
    XK_x :: 0x0078;
    XK_y :: 0x0079;
    XK_z :: 0x007a;

    XK_0 :: 0x0030;
    XK_1 :: 0x0031;
    XK_2 :: 0x0032;
    XK_3 :: 0x0033;
    XK_4 :: 0x0034;
    XK_5 :: 0x0035;
    XK_6 :: 0x0036;
    XK_7 :: 0x0037;
    XK_8 :: 0x0038;
    XK_9 :: 0x0039;

    XK_F1 :: 0xFFBE;
    XK_F2 :: 0xFFBF;
    XK_F3 :: 0xFFC0;
    XK_F4 :: 0xFFC1;
    XK_F5 :: 0xFFC2;
    XK_F6 :: 0xFFC3;
    XK_F7 :: 0xFFC4;
    XK_F8 :: 0xFFC5;
    XK_F9 :: 0xFFC6;
    XK_F10 :: 0xFFC7;
    XK_F11 :: 0xFFC8;
    XK_F12 :: 0xFFC9;

    XK_space :: 0x0020;
    XK_Return :: 0xFF0D;
    XK_Escape :: 0xFF1B;
    XK_Tab :: 0xFF09;
    XK_Up :: 0xFF52;
    XK_Down :: 0xFF54;
    XK_Left :: 0xFF51;
    XK_Right :: 0xFF53;
}

#if OS != .WINDOWS {
    VK_SPACE :: 0x20;
    VK_RETURN :: 0x0D;
    VK_ESCAPE :: 0x1B;
    VK_TAB :: 0x09;
    VK_UP :: 0x26;
    VK_DOWN :: 0x28;
    VK_LEFT :: 0x25;
    VK_RIGHT :: 0x27;
}

init_key_map :: () {
    
    table_add(*key_map, .A, .{XK_a, #char "A", 0x00});
    table_add(*key_map, .B, .{XK_b, #char "B", 0x0B});
    table_add(*key_map, .C, .{XK_c, #char "C", 0x08});
    table_add(*key_map, .D, .{XK_d, #char "D", 0x02});
    table_add(*key_map, .E, .{XK_e, #char "E", 0x0E});
    table_add(*key_map, .F, .{XK_f, #char "F", 0x03});
    table_add(*key_map, .G, .{XK_g, #char "G", 0x05});
    table_add(*key_map, .H, .{XK_h, #char "H", 0x04});
    table_add(*key_map, .I, .{XK_i, #char "I", 0x22});
    table_add(*key_map, .J, .{XK_j, #char "J", 0x26});
    table_add(*key_map, .K, .{XK_k, #char "K", 0x28});
    table_add(*key_map, .L, .{XK_l, #char "L", 0x25});
    table_add(*key_map, .M, .{XK_m, #char "M", 0x2E});
    table_add(*key_map, .N, .{XK_n, #char "N", 0x2D});
    table_add(*key_map, .O, .{XK_o, #char "O", 0x1F});
    table_add(*key_map, .P, .{XK_p, #char "P", 0x23});
    table_add(*key_map, .Q, .{XK_q, #char "Q", 0x0C});
    table_add(*key_map, .R, .{XK_r, #char "R", 0x0F});
    table_add(*key_map, .S, .{XK_s, #char "S", 0x01});
    table_add(*key_map, .T, .{XK_t, #char "T", 0x11});
    table_add(*key_map, .U, .{XK_u, #char "U", 0x20});
    table_add(*key_map, .V, .{XK_v, #char "V", 0x09});
    table_add(*key_map, .W, .{XK_w, #char "W", 0x0D});
    table_add(*key_map, .X, .{XK_x, #char "X", 0x07});
    table_add(*key_map, .Y, .{XK_y, #char "Y", 0x10});
    table_add(*key_map, .Z, .{XK_z, #char "Z", 0x06});
    
    table_add(*key_map, .NUM_0, .{XK_0, #char "0", 0x1D});
    table_add(*key_map, .NUM_1, .{XK_1, #char "1", 0x12});
    table_add(*key_map, .NUM_2, .{XK_2, #char "2", 0x13});
    table_add(*key_map, .NUM_3, .{XK_3, #char "3", 0x14});
    table_add(*key_map, .NUM_4, .{XK_4, #char "4", 0x15});
    table_add(*key_map, .NUM_5, .{XK_5, #char "5", 0x17});
    table_add(*key_map, .NUM_6, .{XK_6, #char "6", 0x16});
    table_add(*key_map, .NUM_7, .{XK_7, #char "7", 0x1A});
    table_add(*key_map, .NUM_8, .{XK_8, #char "8", 0x1C});
    table_add(*key_map, .NUM_9, .{XK_9, #char "9", 0x19});

    table_add(*key_map, .F1, .{XK_F1, 112, 122});
    table_add(*key_map, .F2, .{XK_F2, 113, 120});
    table_add(*key_map, .F3, .{XK_F3, 114, 99});
    table_add(*key_map, .F4, .{XK_F4, 115, 118});
    table_add(*key_map, .F5, .{XK_F5, 116, 96});
    table_add(*key_map, .F6, .{XK_F6, 117, 97});
    table_add(*key_map, .F7, .{XK_F7, 118, 98});
    table_add(*key_map, .F8, .{XK_F8, 119, 100});
    table_add(*key_map, .F9, .{XK_F9, 120, 101});
    table_add(*key_map, .F10, .{XK_F10, 121, 109});
    table_add(*key_map, .F11, .{XK_F11, 122, 103});
    table_add(*key_map, .F12, .{XK_F12, 123, 111});
    
    table_add(*key_map, .SPACE, .{XK_space, VK_SPACE, 0x31});
    table_add(*key_map, .ENTER, .{XK_Return, VK_RETURN, 0x24});
    table_add(*key_map, .ESCAPE, .{XK_Escape, VK_ESCAPE, 0x35});
    table_add(*key_map, .TAB, .{XK_Tab, VK_TAB, 0x30});

    table_add(*key_map, .UP, .{XK_Up, VK_UP, 0x7E});
    table_add(*key_map, .DOWN, .{XK_Down, VK_DOWN, 0x7D});
    table_add(*key_map, .LEFT, .{XK_Left, VK_LEFT, 0x7B});
    table_add(*key_map, .RIGHT, .{XK_Right, VK_RIGHT, 0x7C});
}

get_platform_keycode :: (key: Key) -> u32 {
    #if OS == .LINUX {
        found, code := table_find(*key_map, key);
        if found return code.x11;
    } #if OS == .WINDOWS {
        found, code := table_find(*key_map, key);
        if found return code.windows;
    } #if OS == .MACOS {
        found, code := table_find(*key_map, key);
        if found return code.macos;
    }
    return 0;
}

from_platform_keycode :: (keycode: u32) -> Key {
    for code, key: key_map {
        #if OS == .LINUX {
            if code.x11 == keycode return key;
        } #if OS == .WINDOWS {
            if code.windows == keycode return key;
        } #if OS == .MACOS {
            if code.macos == keycode return key;
        }
    }
    return .A; // Should not happen
}