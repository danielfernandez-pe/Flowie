// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Flowie",
    platforms: [.iOS(.v18)],
    products: [
        .library(name: "Flowie", targets: ["Flowie"]),
    ],
    dependencies: [
        .package(url: "git@github.com:danielfernandez-pe/Logger.git", from: "1.2.1")
    ],
    targets: [
        .target(
            name: "Flowie",
            dependencies: [
                .product(name: "Lumberjack", package: "Logger"),
            ],
            path: "Sources",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "FlowieTests",
            dependencies: ["Flowie"]
        ),
    ]
)
