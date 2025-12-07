// build_example.jai

#import "Basic";
#import "Compiler";

#run {
    example_w := compiler_create_workspace("system_hotkey_example");
    if !example_w {
        print("Couldn't create example workspace.\n");
        exit(-1);
    }

    example_options := get_build_options(example_w);
    new_example_import_path: [..] string;
    for example_options.import_path {
        array_add(*new_example_import_path, it);
    }
    array_add(*new_example_import_path, "jai_src"); // Add jai_src to import path for example
    example_options.import_path = new_example_import_path;
    example_options.output_executable_name = "system_hotkey_example";
    example_options.output_path = "."; // Specify the output path
    set_build_options(example_options, example_w);

    // Set this workspace as the target
    set_build_options_dc(.{do_output=false});

    compiler_begin_intercept(example_w);
    add_build_file("example.jai", example_w);

    print("Building system_hotkey_example...\n");

    while true {
        message := compiler_wait_for_message();
        if !message break;

        if message.kind == .COMPLETE {
            print("Build complete!\n");
            break;
        }
    }

    compiler_end_intercept(example_w);
}

