// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "NioWorker",
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio", from: "2.87.0")
    ],
    targets: [
        .executableTarget(
            name: "NioWorker",
            dependencies: [
                .product(name: "NIOPosix", package: "swift-nio"),
                .product(name: "NIOHTTP1", package: "swift-nio"),
                .product(name: "NIOCore", package: "swift-nio"),
            ]
        ),
    ]
)
