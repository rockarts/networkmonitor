// swift-tools-version: 5.10
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "NetworkMonitor",
    platforms: [
        .macOS(.v12), .iOS(.v15), .tvOS(.v15), .watchOS(.v8)
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
