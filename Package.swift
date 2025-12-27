// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "TimerApp",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "TimerApp",
            targets: ["TimerApp"]
        )
    ],
    targets: [
        .executableTarget(
            name: "TimerApp",
            dependencies: [],
            path: ".",
            exclude: [
                "Timer_Description.md",
                "build.sh",
                "README.md",
                "create_icon.sh",
                "create_app_bundle.sh",
                "AppIcon.icns",
                "TimerApp.app"
            ],
            sources: ["TimerApp.swift", "TimerContentView.swift"]
        )
    ]
)

