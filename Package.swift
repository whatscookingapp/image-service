// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "push-service",
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/jwt.git", from: "3.0.0"),
        .package(url: "https://github.com/jimmya/onesignal.git", .branch("master")),
        .package(url: "https://github.com/vapor-community/vapor-ext.git", from: "0.3.0")
    ],
    targets: [
        .target(name: "App", dependencies: ["JWT", "Vapor", "OneSignal", "ServiceExt"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)
