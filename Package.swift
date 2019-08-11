// swift-tools-version:5.1
import PackageDescription

let package = Package(
    name: "Restructure",
    platforms: [
        .macOS(.v10_14), .iOS(.v12), .tvOS(.v12), .watchOS(.v5)
    ],
    products: [
        .library(
            name: "Restructure",
            targets: ["Restructure"]
        ),
    ],
    targets: [
        .target(name: "Restructure"),
        .testTarget(
            name: "RestructureTests",
            dependencies: ["Restructure"]
        ),
    ]
)
