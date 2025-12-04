// jai_src/tests/test_main.jai

#import "Basic";
#load "../system_hotkey.jai";
#load "test_harness.jai";
#load "init_test.jai";
#load "register_test.jai";

main :: () {
    print("Running tests...\n");

    run_init_test();
    run_register_test();

    print("All tests passed.\n");
}
