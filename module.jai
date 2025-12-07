// Jai System Hotkey Module
// Cross-platform system-wide hotkey support for Windows, macOS, and Linux (X11)
//
// Usage:
//   #import "jai-system-hotkey";
//
//   ctx := init();
//   defer shutdown(ctx);
//
//   hotkey := Hotkey.{ modifiers = .CONTROL | .SHIFT, key = .P };
//   register_hotkey(ctx, hotkey, my_callback, null);
//
//   while running {
//       poll_events(ctx);
//       sleep_milliseconds(10);
//   }

#module_parameters(DEBUG := false);

// Load the main system hotkey implementation
#load "jai_src/system_hotkey.jai";
