// swift-tools-version: 5.8
import PackageDescription

let package = Package(
    name: "EmailClient",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "EmailClient",
            targets: ["EmailClient"]
        )
    ],
    dependencies: [
        // Keychain Services wrapper
        .package(url: "https://github.com/evgenyneu/keychain-swift", from: "20.0.0"),
        // OAuth2 and HTTP client
        .package(url: "https://github.com/Alamofire/Alamofire", from: "5.7.0"),
        // JSON parsing
        .package(url: "https://github.com/Flight-School/AnyCodable", from: "0.6.0"),
        // Async extensions
        .package(url: "https://github.com/apple/swift-async-algorithms", from: "0.1.0")
    ],
    targets: [
        .executableTarget(
            name: "EmailClient",
            dependencies: [
                .product(name: "KeychainSwift", package: "keychain-swift"),
                "Alamofire",
                "AnyCodable",
                .product(name: "AsyncAlgorithms", package: "swift-async-algorithms")
            ]
        ),
        .testTarget(
            name: "EmailClientTests",
            dependencies: ["EmailClient"]
        )
    ]
)