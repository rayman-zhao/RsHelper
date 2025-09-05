// swift-tools-version: 6.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "RsHelper",
    platforms: [
    	.macOS(.v15),
    ],
    products: [
        .library(
            name: "RsHelper",
            targets: ["RsHelper"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
    ],
    targets: [
        .target(
            name: "RsHelper",
            dependencies: [
                .product(name: "Logging", package: "swift-log"),
            ],
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
