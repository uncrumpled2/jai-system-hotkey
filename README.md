# system-hotkey-jai

A cross-platform library for creating system-wide hotkeys in the Jai programming language.

## Features

*   **Cross-platform:** Supports Windows, macOS, and Linux (X11).
*   **Easy to use:** Simple API for registering and unregistering hotkeys.
*   **Flexible:** Use callbacks or poll for hotkey events.
*   **FFI-friendly:** Can be used from other languages like Python.

## Installation

To build the library, you will need the Jai compiler.

Once you have the Jai compiler installed, you can build the library by running the following command in the root of the project:

```
jai build.jai
```

This will create a shared library file (`.so` on Linux, `.dll` on Windows, `.dylib` on macOS) in the project's root directory.

## Usage

Here is an example of how to use the library in Jai:

```jai
#import "system_hotkey";

main :: () {
    context := init();
    if !context {
        print("Failed to initialize system hotkey context.\n");
        return;
    }
    defer shutdown(context);

    my_callback :: (hotkey: Hotkey, user_data: *void) {
        print("Hotkey pressed: %\n", hotkey);
    }

    hotkey_to_register: Hotkey = .{
        modifiers = .[CONTROL, SHIFT],
        key = .A
    };

    if register_hotkey(context, hotkey_to_register, my_callback, null) {
        print("Hotkey registered successfully!\n");
    } else {
        print("Failed to register hotkey.\n");
    }

    while true {
        poll_events(context);
        sleep_milliseconds(10);
    }
}
```

## FFI Usage

Here is an example of how to use the library from Python:

```python
import ctypes
from enum import Enum

# Define the Hotkey struct
class C_Hotkey(ctypes.Structure):
    _fields_ = [("modifiers", ctypes.c_uint),
                ("key", ctypes.c_uint)]

# Define the enums for modifiers and keys
class Modifier(Enum):
    NONE = 0x0
    CONTROL = 0x1
    SHIFT = 0x2
    ALT = 0x4
    SUPER = 0x8

class Key(Enum):
    A = 0
    # ... and so on

# Load the shared library
lib = ctypes.CDLL("./system_hotkey.so") # Change the extension based on your OS

# Define the function signatures
system_hotkey_init = lib.system_hotkey_init
system_hotkey_init.restype = ctypes.c_void_p

system_hotkey_shutdown = lib.system_hotkey_shutdown
system_hotkey_shutdown.argtypes = [ctypes.c_void_p]

system_hotkey_register = lib.system_hotkey_register
system_hotkey_register.argtypes = [ctypes.c_void_p, C_Hotkey]
system_hotkey_register.restype = ctypes.c_bool

system_hotkey_unregister = lib.system_hotkey_unregister
system_hotkey_unregister.argtypes = [ctypes.c_void_p, C_Hotkey]
system_hotkey_unregister.restype = ctypes.c_bool

system_hotkey_poll_events = lib.system_hotkey_poll_events
system_hotkey_poll_events.argtypes = [ctypes.c_void_p]

system_hotkey_get_triggered_hotkeys = lib.system_hotkey_get_triggered_hotkeys
system_hotkey_get_triggered_hotkeys.argtypes = [ctypes.c_void_p]
system_hotkey_get_triggered_hotkeys.restype = ctypes.POINTER(C_Hotkey)

# Initialize the library
context = system_hotkey_init()

# Register a hotkey
hotkey = C_Hotkey(modifiers=Modifier.CONTROL.value | Modifier.SHIFT.value, key=Key.A.value)
system_hotkey_register(context, hotkey)

# Poll for events
while True:
    system_hotkey_poll_events(context)
    triggered_hotkeys = system_hotkey_get_triggered_hotkeys(context)
    for i in range(triggered_hotkeys.contents.count):
        print(f"Hotkey pressed: {triggered_hotkeys.contents[i].modifiers} {triggered_hotkeys.contents[i].key}")
    # Free the memory allocated by get_triggered_hotkeys
    # ...

# Shutdown the library
system_hotkey_shutdown(context)

```

**Note:** The `system_hotkey_get_triggered_hotkeys` function returns a slice, which is a pointer to the data and a count. You will need to handle this correctly in your Python code to avoid memory leaks.

## API Reference

### `init() -> *System_Hotkey_Context`

Initializes the library and returns a context object.

### `shutdown(context: *System_Hotkey_Context)`

Shuts down the library and frees the context object.

### `register_hotkey(context: *System_Hotkey_Context, hotkey: Hotkey, callback: Hotkey_Callback, user_data: *void) -> bool`

Registers a hotkey.

*   `context`: The context object returned by `init`.
*   `hotkey`: The hotkey to register.
*   `callback`: The function to call when the hotkey is pressed.
*   `user_data`: A pointer to user data that will be passed to the callback.
*   Returns `true` if the hotkey was registered successfully, `false` otherwise.

### `unregister_hotkey(context: *System_Hotkey_Context, hotkey: Hotkey) -> bool`

Unregisters a hotkey.

*   `context`: The context object returned by `init`.
*   `hotkey`: The hotkey to unregister.
*   Returns `true` if the hotkey was unregistered successfully, `false` otherwise.

### `poll_events(context: *System_Hotkey_Context)`

Polls for hotkey events. This function should be called repeatedly in a loop.

### FFI Functions

The FFI functions are the same as the Jai functions, but they are exposed with a C calling convention. See the "FFI Usage" section for an example.


