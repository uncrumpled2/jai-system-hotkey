// log.jai
#import "Basic";

log_error :: (message: string, args: ..Any) {
    print("Error: ");
    print(message, ..args);
    print("\n");
}
