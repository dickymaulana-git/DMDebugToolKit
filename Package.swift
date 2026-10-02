// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "DMDebugToolKit",

    platforms: [
        .iOS(.v15)
    ],

    products: [
        .library(
            name: "DMDebugToolKit",
            targets: ["DMDebugToolKit"]
        ),
        .library(
            name: "DMDebugToolKitMoya",
            targets: ["DMDebugToolKitMoya"]
        )
    ],

    dependencies: [
        .package(
            url: "https://github.com/Moya/Moya.git",
            from: "15.0.3"
        )
    ],

    targets: [
        .target(
            name: "DMDebugToolKit",
            resources: [
                .process("Resources")
            ]
        ),
        .target(
            name: "DMDebugToolKitMoya",
            dependencies: [
                "DMDebugToolKit",
                .product(
                    name: "Moya",
                    package: "Moya"
                )
            ]
        ),
        .testTarget(
            name: "DMDebugToolKitTests",
            dependencies: [
                "DMDebugToolKit"
            ]
        )
    ]
)
