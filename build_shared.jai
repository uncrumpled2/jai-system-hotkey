// build_shared.jai - Build system_hotkey as a shared library for FFI

#import "Basic";
#import "Compiler";
#import "File";

build :: () {
    w := compiler_create_workspace("system_hotkey_shared");
    if !w {
        print("Failed to create workspace\n");
        return;
    }

    options := get_build_options(w);
    options.output_executable_name = "system_hotkey";
    options.output_type = .DYNAMIC_LIBRARY;

    // Output to lib directory
    make_directory_if_it_does_not_exist("lib");
    options.output_path = "lib";


    set_build_options(options, w);

    compiler_begin_intercept(w);

    // Add the main module (ffi.jai is #load'ed from system_hotkey.jai)
    add_build_file("jai_src/system_hotkey.jai", w);

    while true {
        message := compiler_wait_for_message();
        if message.kind == .COMPLETE break;
    }

    compiler_end_intercept(w);
}

#run build();
