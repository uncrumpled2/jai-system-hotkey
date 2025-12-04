// jai_src/tests/register_test.jai

#import "Basic";
#load "test_harness.jai";
#load "../enums.jai";
#load "../system_hotkey.jai";

run_register_test :: () {
    print("Running register test...\n");

    ctx := init();
    assert(ctx != null, "init() should return a valid context.");

    callback :: (hotkey: Hotkey, user_data: *void) {
        // Do nothing
    }

    hotkey: Hotkey = .{
        modifiers = .[CONTROL, SHIFT],
        key = .A
    };

    assert(register_hotkey(ctx, hotkey, callback, null), "register_hotkey should return true.");
    assert(unregister_hotkey(ctx, hotkey), "unregister_hotkey should return true.");

    shutdown(ctx);
}

