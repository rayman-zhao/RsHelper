// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RsHelper",
    products: [
        .library(
            name: "RsHelper",
            targets: ["RsHelper"]
        ),
    ],
    targets: [
        .target(
            name: "RsHelper"
        ),
        .testTarget(
            name: "RsHelperTests",
            dependencies: ["RsHelper"],
            resources: [
            	.copy("Resources/"),
            ],
        ),
    ]
)
