// example.jai

#import "Basic";
#load "jai_src/system_hotkey.jai";

my_callback :: (hotkey: Hotkey, user_data: *void) {
    print("Hello, sailor!\n");
}

main :: () {
    print("Starting system hotkey example...\n");

    // Initialize with verbose=true to see debug output
    ctx := init(verbose=true);
    if !ctx {
        print("Failed to initialize system hotkey context.\n");
        return;
    }
    defer shutdown(ctx);

    hotkey_to_register: Hotkey = .{
        modifiers = .NONE,
        key = .F5
    };

    if register_hotkey(ctx, hotkey_to_register, my_callback, null) {
        print("F5 hotkey registered successfully! Press F5 to see a message.\n");
        print("Press Ctrl+C to exit.\n");
    } else {
        print("Failed to register F5 hotkey.\n");
        return;
    }

    while true {
        poll_events(ctx);
        sleep_milliseconds(10); // Sleep for a short duration to avoid busy-waiting
    }
}
