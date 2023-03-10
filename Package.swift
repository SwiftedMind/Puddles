// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Puddles",
		platforms: [.iOS(.v15), .macOS(.v12)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
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
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.1.0")
    ],
    targets: [
        .target(
            name: "Puddles",
            dependencies: [
            ]
        ),
        .target(
            name: "PreviewDebugTools",
            dependencies: [
                "Puddles"
            ]
        )
    ]
)
