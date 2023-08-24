// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Puddles",
		platforms: [
            .iOS(.v15),
            .macOS(.v12),
            .watchOS(.v8),
            .tvOS(.v15)
        ],
    products: [
        .library(
            name: "Puddles",
            targets: ["Puddles"]
        )
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Puddles"
        )
    ]
)
