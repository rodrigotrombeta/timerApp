# Timer App for macOS

A simple timer application that lives in the macOS menu bar.

- Popover with interval and repetition configuration
- Visual countdown
- Sound alert when each interval finishes
- Multiple repetitions can be set
- Icon blinks when timer finishes
- Quit button in popover and context menu

## Building and Installation

### Step 1: Build the app

```shell
./build.sh
```

### Step 2: Create the icon (optional, but recommended)

```shell
./create_icon.sh
```

This will create the `AppIcon.icns` file with the same timer icon used in the menu bar.

### Step 3: Create the .app bundle

```shell
./create_app_bundle.sh
```

This will create the `TimerApp.app` file in the project folder. The script automatically includes the icon if it exists.

### Step 4: Install to Applications folder

Drag `TimerApp.app` to the Applications folder

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
- `build.sh` - Script to build the app
- `create_icon.sh` - Script to create the .icns icon file
- `create_app_bundle.sh` - Script to create the installable .app bundle

## License

This project is open source. Feel free to modify and use it as you wish.
