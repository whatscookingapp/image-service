// swift-tools-version:5.2
import PackageDescription

let package = Package(
    name: "app",
    platforms: [
       .macOS(.v10_15),
    ],
    products: [
        .executable(name: "Run", targets: ["Run"]),
        .library(name: "App", targets: ["App"]),
    ],
    dependencies: [
        // 💧 A server-side Swift web framework.
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0-rc.1"),
        .package(url: "https://github.com/vapor/fluent.git", from: "4.0.0-rc.1"),
        .package(url: "https://github.com/vapor/fluent-postgres-driver.git", from: "2.0.0-rc.1"),
        .package(url: "https://github.com/swift-aws/aws-sdk-swift-core.git", from: "5.0.0-alpha.1")
    ],
    targets: [
        .target(name: "App", dependencies: [
            .product(name: "Fluent", package: "fluent"),
            .product(name: "FluentPostgresDriver", package: "fluent-postgres-driver"),
            .product(name: "Vapor", package: "vapor"),
            .product(name: "AWSSDKSwiftCore", package: "aws-sdk-swift-core"),
        ]),
        .target(name: "Run", dependencies: [
            .target(name: "App"),
        ]),
        .testTarget(name: "AppTests", dependencies: [
            .target(name: "App"),
            .product(name: "XCTVapor", package: "vapor"),
        ])
    ]
)
