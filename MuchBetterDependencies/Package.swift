// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
  name: "MuchBetterDependencies",
  platforms: [
		.iOS(.v15)
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
      name: "Client",
      targets: ["Client"]
    ),
    .library(
      name: "Common",
      targets: ["Common"]
    ),
    .library(
      name: "LoginFeature",
      targets: ["LoginFeature"]
    ),
    .library(
      name: "SpendFeature",
      targets: ["SpendFeature"]
    ),
    .library(
      name: "TransactionFeature",
      targets: ["TransactionFeature"]
    ),
  ],
  dependencies: [
    .package(url: "https://github.com/pointfreeco/swift-composable-architecture",
             from: "1.12.1"),
    .package(url: "https://github.com/pointfreeco/swift-snapshot-testing.git",
             from: "1.17.4"),
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
				.product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
        "BalanceFeature",
        "LoginFeature",
        "SpendFeature",
        "TransactionFeature",
      ],
      exclude: [
        "__Snapshots__",
      ]
    ),
    .target(
      name: "BalanceFeature",
      dependencies: [
        "Common",
				"Client",
				.product(name: "ComposableArchitecture", package: "swift-composable-architecture"),
      ]
    ),
    .testTarget(
      name: "BalanceTests",
      dependencies: [
        "BalanceFeature",
				"Common",
				.product(name: "SnapshotTesting", package: "swift-snapshot-testing"),

      ],
      exclude: [
        "__Snapshots__",
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
				.product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
      ],
      exclude: [
        "__Snapshots__",
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
				.product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
      ],
      exclude: [
        "__Snapshots__",
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
				.product(name: "SnapshotTesting", package: "swift-snapshot-testing"),
      ],
      exclude: [
        "__Snapshots__",
      ]
    ),
  ]
)
