// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Configurations",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "Configurations",
            targets: ["Configurations"]
        ),
    ],
    dependencies: [
        .package(path: "../Configuration"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .upToNextMajor(from: "0.3.0"))
    ],
    targets: [
        .target(
            name: "Configurations",
            dependencies: [
                "Configuration",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .testTarget(
            name: "ConfigurationsTests",
            dependencies: ["Configurations"]),
    ]
)
