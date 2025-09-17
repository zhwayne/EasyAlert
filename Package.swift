// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EasyAlert",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "EasyAlert",
            targets: ["EasyAlert"])
    ],
//    dependencies: [
//        .package(url: "https://github.com/SnapKit/SnapKit.git", .upToNextMajor(from: "5.0.1"))
//    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "EasyAlert",
//            dependencies: [
//                .product(name: "SnapKit", package: "SnapKit")
//            ],
            path: "Sources"
        ),
        .testTarget(
            name: "EasyAlertTests",
            dependencies: ["EasyAlert"],
            path: "Tests"
        )
    ]
)

