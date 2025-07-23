// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Host",
    platforms: [.macOS("26.0"), .iOS("26.0")],
    products: [
        .library(name: "Host", targets: ["Host"]),
        .library(name: "SMARS", targets: ["SMARS"]),
        .library(name: "Tools", targets: ["Tools"])
    ],
    targets: [
        .target(
            name: "Host",
            dependencies: ["SMARS", "Tools"]
        ),
        .target(
            name: "SMARS",
        ),
        .target(
            name: "Tools",
            dependencies: ["SMARS"]
        ),
        .testTarget(
          name: "SMARSTests",
          dependencies: ["SMARS"]
        )
    ]
)
