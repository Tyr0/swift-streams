// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-streams",
    products: [
        .library(
            name: "Streams",
            targets: ["Streams"],
        ),
    ],
    targets: [
        .target(
            name: "Streams",
        ),
        .testTarget(
            name: "StreamsTests",
            dependencies: [
                "Streams",
            ],
        ),
    ],
)
