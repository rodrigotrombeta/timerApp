# Timer App for macOS

A simple timer application that lives in the macOS menu bar.

- Popover with interval and repetition configuration
- Visual countdown
- Sound alert when each interval finishes
- Multiple repetitions can be set
- Icon blinks when timer finishes (3 times, 3 seconds)
- Saves last used interval and repetitions (restored on app restart)
- Supports intervals up to 5 hours
- Quit button in popover and context menu

## Building and Installation

### Build and create the app bundle

Simply run:

```shell
./build.sh
```

This script will:
1. Compile the app executable
2. Create the app icon (if it doesn't exist)
3. Create the `TimerApp.app` bundle with the icon included

The `TimerApp.app` bundle will be created in the project root folder.

### Install to Applications folder

   - Drag `TimerApp.app` to the Applications folder

### Alternative: Using Xcode

1. Open Xcode
2. Create a new macOS App project
3. Replace the generated files with the files from this repository
4. Build and run (⌘R)

## Requirements

- macOS 12.0 or later
- Xcode 13.0 or later
- Swift 5.5 or later

## Project Structure

- `TimerApp.swift` - Application entry point and menu bar configuration
- `TimerContentView.swift` - User interface and timer logic
- `Package.swift` - Swift Package Manager configuration
- `build.sh` - Script to build the app, create icon, and bundle (all-in-one)
- `create_icon.sh` - Script to create the .icns icon file (called automatically by build.sh)
- `create_app_bundle.sh` - Script to create the installable .app bundle (functionality now included in build.sh)

## License

This project is open source. Feel free to modify and use it as you wish.
