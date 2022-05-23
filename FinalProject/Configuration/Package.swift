// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Configuration",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "Configuration",
            targets: ["Configuration"]),
    ],
    dependencies: [
        .package(path: "../Grid"),
        .package(path: "../GameOfLife"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .upToNextMajor(from: "0.3.0"))
    ],
    targets: [
        .target(
            name: "Configuration",
            dependencies: [
                "Grid",
                "GameOfLife",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .testTarget(
            name: "ConfigurationTests",
            dependencies: ["Configuration"]),
    ]
)
