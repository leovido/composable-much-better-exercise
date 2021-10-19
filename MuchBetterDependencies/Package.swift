// swift-tools-version:5.5
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MuchBetterDependencies",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "AppFeature",
            targets: ["AppFeature"]
        ),
        .library(
            name: "BalanceFeature",
            targets: ["BalanceFeature"]
        ),
        .library(
            name: "BalanceTests",
            targets: ["BalanceTests"]
        ),
        .library(
            name: "Client",
            targets: ["Client"]
        ),
        .library(
            name: "Common",
            targets: ["Common"]
        ),
        .library(
            name: "CommonTests",
            targets: ["CommonTests"]
        ),
        .library(
            name: "LoginFeature",
            targets: ["LoginFeature"]
        ),
        .library(
            name: "LoginTests",
            targets: ["LoginTests"]
        ),
        .library(
            name: "SpendFeature",
            targets: ["SpendFeature"]
        ),
        .library(
            name: "SpendTests",
            targets: ["SpendTests"]
        ),
        .library(
            name: "TransactionFeature",
            targets: ["TransactionFeature"]
        ),
        .library(
            name: "TransactionTests",
            targets: ["TransactionTests"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/pointfreeco/swift-composable-architecture", from: "0.28.1"),
        .package(name: "SnapshotTesting", url: "https://github.com/pointfreeco/swift-snapshot-testing.git", from: "1.9.0"),
    ],
    targets: [
        .target(
            name: "AppFeature",
            dependencies: [
                "Client",
                "Common",
                "BalanceFeature",
                "LoginFeature",
                "SpendFeature",
                "TransactionFeature",
            ]
        ),
        .testTarget(
            name: "AppTests",
            dependencies: [
                "AppFeature",
                "SnapshotTesting",
                "BalanceFeature",
                "LoginFeature",
                "SpendFeature",
                "TransactionFeature",
            ]
        ),
        .target(
            name: "BalanceFeature",
            dependencies: [
                "Client",
                "Common",
            ]
        ),
        .testTarget(
            name: "BalanceTests",
            dependencies: [
                "BalanceFeature",
                "SnapshotTesting",
            ]
        ),
        .target(
            name: "Client",
            dependencies: []
        ),
        .target(
            name: "Common",
            dependencies: [
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .testTarget(
            name: "CommonTests",
            dependencies: [
                "Common",
            ]
        ),
        .target(
            name: "LoginFeature",
            dependencies: [
                "Client",
                .product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
            ]
        ),
        .testTarget(
            name: "LoginTests",
            dependencies: [
                "LoginFeature",
                "SnapshotTesting",
            ]
        ),
        .target(
            name: "SpendFeature",
            dependencies: [
                "Client",
                "Common",
            ]
        ),
        .testTarget(
            name: "SpendTests",
            dependencies: [
                "SpendFeature",
                "SnapshotTesting",
            ]
        ),
        .target(
            name: "TransactionFeature",
            dependencies: [
                "Client",
                "Common",
            ]
        ),
        .testTarget(
            name: "TransactionTests",
            dependencies: [
                "TransactionFeature",
                "SnapshotTesting",
            ]
        ),
    ]
)
