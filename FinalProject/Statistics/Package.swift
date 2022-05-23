// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Statistics",
    platforms: [
        .iOS(.v13),
        .macOS(.v10_15),
        .tvOS(.v13),
        .watchOS(.v6),
    ],
    products: [
        .library(
            name: "Statistics",
            targets: ["Statistics"]
        ),
    ],
    dependencies: [
        .package(path: "../GameOfLife"),
        .package(path: "../FunctionalProgramming"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .upToNextMajor(from: "0.3.0"))
    ],
    targets: [
        .target(
            name: "Statistics",
            dependencies: [
                "GameOfLife",
                "FunctionalProgramming",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .testTarget(
            name: "StatisticsTests",
            dependencies: ["Statistics"]),
    ]
)
