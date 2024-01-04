// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "Location",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .tvOS(.v17),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "Location",
            targets: ["Location"]),
    ],
    targets: [
        .target(
            name: "Location"),
        .testTarget(
            name: "LocationTests",
            dependencies: ["Location"]),
    ]
)
