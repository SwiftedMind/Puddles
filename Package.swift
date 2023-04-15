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
        ),
        .library(
            name: "PreviewDebugTools",
            targets: ["PreviewDebugTools"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/SwiftedMind/Queryable", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "Puddles",
            dependencies: [
                "Queryable"
            ]
        ),
        .target(
            name: "PreviewDebugTools",
            dependencies: [
                "Puddles",
                "Queryable"
            ]
        )
    ]
)
