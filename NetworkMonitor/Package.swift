// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkMonitor",
    platforms: [
        .macOS(.v10_15),
        .iOS(.v13),
        .tvOS(.v13),
        .watchOS(.v6)
    ],
    products: [
        .library(
            name: "NetworkMonitor",
            targets: ["NetworkMonitor"]),
        .executable(
            name: "NetworkMonitorCLI",
            targets: ["NetworkMonitorCLI"])
    ],
    dependencies: [],
    targets: [
        .target(
            name: "NetworkMonitor",
            dependencies: []),
        .executableTarget(
            name: "NetworkMonitorCLI",
            dependencies: ["NetworkMonitor"]),
        .testTarget(
            name: "NetworkMonitorTests",
            dependencies: ["NetworkMonitor"]),
    ]
)
