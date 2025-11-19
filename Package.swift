// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Flowie",
    platforms: [.iOS(.v18)],
    products: [
        .library(name: "Flowie", targets: ["Flowie"]),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "Flowie",
            dependencies: [],
            path: "Sources",
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency"),
                .enableUpcomingFeature("InferIsolatedConformances"),
                .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
                .defaultIsolation(MainActor.self)
            ]
        ),
        .testTarget(
            name: "FlowieTests",
            dependencies: ["Flowie"]
        ),
    ]
)
