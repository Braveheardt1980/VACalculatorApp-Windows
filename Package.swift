// swift-tools-version: 5.10
import PackageDescription

let package = Package(
    name: "VACalculatorApp-Windows",
    platforms: [
        .macOS(.v12)
    ],
    products: [
        .executable(
            name: "VACalculatorApp-Windows",
            targets: ["VACalculatorApp-Windows"]
        )
    ],
    dependencies: [
        // SwiftCrossUI - Cross-platform UI framework inspired by SwiftUI
        .package(url: "https://github.com/stackotter/swift-cross-ui", branch: "main"),
        
        // CryptoSwift - Cryptographic algorithms for license system
        .package(url: "https://github.com/krzyzanowskim/CryptoSwift", from: "1.8.0"),
        
        // Swift Crypto - Additional cryptographic support
        .package(url: "https://github.com/apple/swift-crypto", from: "3.0.0")
    ],
    targets: [
        .executableTarget(
            name: "VACalculatorApp-Windows",
            dependencies: [
                .product(name: "SwiftCrossUI", package: "swift-cross-ui"),
                .product(name: "DefaultBackend", package: "swift-cross-ui"),
                .product(name: "CryptoSwift", package: "CryptoSwift"),
                .product(name: "Crypto", package: "swift-crypto")
            ],
            path: "Source",
            sources: [
                "main_simple.swift",
                "Models/",
                "Services/FilterCalculationService.swift",
                "Services/FormulaService.swift",
                "Services/UnifiedCalculationService.swift"
            ],
            resources: [
                .copy("../Assets")
            ]
        ),
        .testTarget(
            name: "VACalculatorApp-WindowsTests",
            dependencies: ["VACalculatorApp-Windows"],
            path: "Tests"
        )
    ]
)