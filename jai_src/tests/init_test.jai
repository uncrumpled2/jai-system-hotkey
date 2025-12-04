// jai_src/tests/init_test.jai

#import "Basic";
#load "test_harness.jai";
#load "../enums.jai";
#load "../system_hotkey.jai";

run_init_test :: () {
    print("Running init test...\n");

    ctx := init();
    assert(ctx != null, "init() should return a valid context.");

    shutdown(ctx);
}
