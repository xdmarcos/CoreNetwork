// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "CoreNetwork",
    platforms: [
        .iOS(.v15),
        .macOS(.v12),
        .tvOS(.v15),
        .watchOS(.v8)
    ],
    products: [
        .library(
            name: "CoreNetwork",
            targets: ["CoreNetwork"]),
    ],
    targets: [
        .target(
            name: "CoreNetwork"),
        .testTarget(
            name: "CoreNetworkTests",
            dependencies: ["CoreNetwork"]),
    ]
)
