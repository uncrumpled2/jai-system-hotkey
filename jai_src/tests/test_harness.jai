// jai_src/tests/test_harness.jai

#import "Basic";

assert :: (condition: bool, message: string) {
    if !condition {
        print("Assertion failed: %\n", message);
        exit(-1);
    }
}
