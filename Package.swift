// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "StreamingKit",
    platforms: [
        .iOS(.v17),        // or whatever iOS version you're targeting
        .macOS(.v14)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "StreamingKit",
            targets: ["StreamingKit"]),
    ],
    
    dependencies: [
        .package(url: "https://github.com/livekit/client-sdk-ios.git", .upToNextMajor(from: "2.6.0"))
        ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "StreamingKit",
            dependencies: [
                .product(name: "LiveKit", package: "client-sdk-ios")
            ]
        )
        
    ]
)
