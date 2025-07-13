// swift-tools-version:6.1

import PackageDescription

let package = Package(
    name: "Restructure",
    platforms: [
        .macOS(.v14), .iOS(.v17), .tvOS(.v17), .watchOS(.v9), .visionOS(.v2)
    ],
    products: [
        .library(
            name: "Restructure",
            targets: ["Restructure"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.0.0"),
        .package(url: "https://github.com/SimplyDanny/SwiftLintPlugins", from: "0.59.1")
    ],
    targets: [
        .target(
            name: "Restructure",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ],
            plugins: [.plugin(name: "SwiftLintBuildToolPlugin", package: "SwiftLintPlugins")],
        ),
        .testTarget(
            name: "RestructureTests",
            dependencies: ["Restructure"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
    ]
)
