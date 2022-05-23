// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Simulation",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "Simulation",
            targets: ["Simulation"]
        ),
    ],
    dependencies: [
        .package(path: "../Grid"),
        .package(path: "../GameOfLife"),
        .package(path: "../FunctionalProgramming"),
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", .upToNextMajor(from: "0.3.0"))
    ],
    targets: [
        .target(
            name: "Simulation",
            dependencies: [
                "Grid",
                "GameOfLife",
                "FunctionalProgramming",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture")
            ]
        ),
        .testTarget(
            name: "SimulationTests",
            dependencies: ["Simulation"]
        ),
    ]
)
