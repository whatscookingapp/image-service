// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "image-service",
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/twostraws/SwiftGD.git", .upToNextMinor(from: "2.3.0")),
        .package(url: "https://github.com/vapor-community/vapor-ext.git", from: "0.3.0"),
        .package(url: "https://github.com/LiveUI/S3.git", from: "3.0.0-RC3.2"),
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "SwiftGD", "S3", "ServiceExt"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)
