// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Clarity",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16),
    ],
    products: [
        .iOSApplication(
            name: "Clarity",
            targets: ["Clarity"],
            bundleIdentifier: "com.dikashma.demoios.Clarity.com.tariq",
            teamIdentifier: "BAQD6767H2",
            displayVersion: "1.0",
            bundleVersion: "1",
            appIcon: .asset("AppIcon"),
            accentColor: .asset("AccentColor"),
            supportedDeviceFamilies: [
                .phone,
                .pad
            ],
            supportedInterfaceOrientations: [
                .portrait,
                .landscapeRight,
                .landscapeLeft
            ],
            capabilities: [
                .camera(),
                .photoLibrary(),
                .microphone(),
            ],
            additionalInfoPlistContentFilePath: "Clarity/Info.plist"
        )
    ],
    targets: [
        .target(
            name: "Clarity",
            path: "Clarity",
            resources: [
                .process("Assets.xcassets"),
                .process("Preview Content")
            ]
        )
    ],
    dependencies: [
        .package(name: "SwiftUI"),
        .package(name: "VisionKit"),
        .package(name: "Vision"),
        .package(name: "AVFoundation"),
        .package(name: "CoreHaptics"),
    ]
) 
