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
                "Extensions",
                "NumbersAPI",
                "CultureMinds",
                "MockData"
            ]),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-identified-collections", from: "0.7.1"),
        .package(url: "https://github.com/kean/Get", from: "2.1.6"),
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
        ),.target(
            name: "MockData",
            dependencies: [
                .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
                "Models"
            ]
        ),
        .target(
            name: "CultureMinds",
            dependencies: [
                .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
                "MockData"
            ]
        ),
        .target(
            name: "NumbersAPI",
            dependencies: [
                .product(name: "IdentifiedCollections", package: "swift-identified-collections"),
                "Get",
                "MockData"
            ]
        )
    ]
)
