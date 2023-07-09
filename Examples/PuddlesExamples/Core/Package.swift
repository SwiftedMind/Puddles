// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "Core",
    platforms: [.iOS(.v16)],
    products: [
        .library(
            name: "Core",
            targets: [
                "Models",
                "ScrumStore",
                "AudioRecording",
                "MockData",
                "Extensions"
            ]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "0.7.1")
    ],
    targets: [
        .target(
            name: "Models",
            dependencies: [
                .product(name: "IdentifiedCollections", package: "swift-identified-collections")
            ]
        ),
        .target(
            name: "Extensions",
            dependencies: [
                .product(name: "IdentifiedCollections", package: "swift-identified-collections")
            ]
        ),
        .target(
            name: "AudioRecording",
            dependencies: [
                .product(name: "IdentifiedCollections", package: "swift-identified-collections")
            ]
        ),
        .target(
            name: "MockData",
            dependencies: [
                .product(name: "IdentifiedCollections", package: "swift-identified-collections")
            ]
        ),
        .target(
            name: "ScrumStore",
            dependencies: [
                .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
                "Models"
            ]
        )
    ]
)
