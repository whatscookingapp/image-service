// swift-tools-version:5.0
import PackageDescription

let package = Package(
    name: "image-service",
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "3.0.0"),
        .package(url: "https://github.com/vapor/fluent-postgresql.git", from: "1.0.0"),
        .package(url: "https://github.com/vapor-community/vapor-ext.git", from: "0.3.0"),
        .package(url: "https://github.com/LiveUI/S3.git", from: "3.0.0-RC3.2"),
        .package(url: "https://gitlab.com/jimmya92/oauthvalidator.git", .branch("master")),
        .package(url: "https://gitlab.com/food-sharing/scopes.git", .branch("master")),
    ],
    targets: [
        .target(name: "App", dependencies: ["Vapor", "FluentPostgreSQL", "S3", "ServiceExt", "OAuthValidator", "scopes"]),
        .target(name: "Run", dependencies: ["App"]),
        .testTarget(name: "AppTests", dependencies: ["App"])
    ]
)
