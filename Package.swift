// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "iOSEnterpriseDeploymentFramework",
    platforms: [
        .iOS(.v15),
        .macOS(.v12)
    ],
    products: [
        .library(
            name: "EnterpriseDeploymentCore",
            targets: ["EnterpriseDeploymentCore"]
        ),
        .library(
            name: "EnterpriseMDM",
            targets: ["EnterpriseMDM"]
        ),
        .library(
            name: "EnterpriseDistribution",
            targets: ["EnterpriseDistribution"]
        ),
        .library(
            name: "EnterpriseCompliance",
            targets: ["EnterpriseCompliance"]
        ),
        .library(
            name: "EnterpriseAnalytics",
            targets: ["EnterpriseAnalytics"]
        ),
        .executable(
            name: "EnterpriseDeploymentCLI",
            targets: ["EnterpriseDeploymentCLI"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-crypto.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-log.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-nio.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-nio-ssl.git", from: "2.0.0"),
        .package(url: "https://github.com/apple/swift-nio-extras.git", from: "1.0.0")
    ],
    targets: [
        // MARK: - Core Framework
        .target(
            name: "EnterpriseDeploymentCore",
            dependencies: [
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "Logging", package: "swift-log"),
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOSSL", package: "swift-nio-ssl")
            ],
            path: "Sources/Core",
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                .define("RELEASE", .when(configuration: .release))
            ]
        ),
        
        // MARK: - MDM Integration
        .target(
            name: "EnterpriseMDM",
            dependencies: [
                "EnterpriseDeploymentCore",
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Sources/MDM",
            swiftSettings: [
                .define("MDM_ENABLED", .when(configuration: .debug)),
                .define("MDM_ENABLED", .when(configuration: .release))
            ]
        ),
        
        // MARK: - App Distribution
        .target(
            name: "EnterpriseDistribution",
            dependencies: [
                "EnterpriseDeploymentCore",
                "EnterpriseMDM",
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "NIOExtras", package: "swift-nio-extras")
            ],
            path: "Sources/Distribution",
            swiftSettings: [
                .define("DISTRIBUTION_ENABLED", .when(configuration: .debug)),
                .define("DISTRIBUTION_ENABLED", .when(configuration: .release))
            ]
        ),
        
        // MARK: - Compliance Framework
        .target(
            name: "EnterpriseCompliance",
            dependencies: [
                "EnterpriseDeploymentCore",
                "EnterpriseMDM",
                .product(name: "Crypto", package: "swift-crypto"),
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Sources/Compliance",
            swiftSettings: [
                .define("COMPLIANCE_ENABLED", .when(configuration: .debug)),
                .define("COMPLIANCE_ENABLED", .when(configuration: .release))
            ]
        ),
        
        // MARK: - Analytics Framework
        .target(
            name: "EnterpriseAnalytics",
            dependencies: [
                "EnterpriseDeploymentCore",
                "EnterpriseDistribution",
                .product(name: "NIO", package: "swift-nio"),
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Sources/Analytics",
            swiftSettings: [
                .define("ANALYTICS_ENABLED", .when(configuration: .debug)),
                .define("ANALYTICS_ENABLED", .when(configuration: .release))
            ]
        ),
        
        // MARK: - CLI Tool
        .executableTarget(
            name: "EnterpriseDeploymentCLI",
            dependencies: [
                "EnterpriseDeploymentCore",
                "EnterpriseMDM",
                "EnterpriseDistribution",
                "EnterpriseCompliance",
                "EnterpriseAnalytics",
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Logging", package: "swift-log")
            ],
            path: "Sources/CLI"
        ),
        
        // MARK: - Tests
        .testTarget(
            name: "EnterpriseDeploymentCoreTests",
            dependencies: [
                "EnterpriseDeploymentCore",
                .product(name: "NIO", package: "swift-nio")
            ],
            path: "Tests/Core"
        ),
        
        .testTarget(
            name: "EnterpriseMDMTests",
            dependencies: [
                "EnterpriseMDM",
                "EnterpriseDeploymentCore"
            ],
            path: "Tests/MDM"
        ),
        
        .testTarget(
            name: "EnterpriseDistributionTests",
            dependencies: [
                "EnterpriseDistribution",
                "EnterpriseDeploymentCore"
            ],
            path: "Tests/Distribution"
        ),
        
        .testTarget(
            name: "EnterpriseComplianceTests",
            dependencies: [
                "EnterpriseCompliance",
                "EnterpriseDeploymentCore"
            ],
            path: "Tests/Compliance"
        ),
        
        .testTarget(
            name: "EnterpriseAnalyticsTests",
            dependencies: [
                "EnterpriseAnalytics",
                "EnterpriseDeploymentCore"
            ],
            path: "Tests/Analytics"
        ),
        
        .testTarget(
            name: "EnterpriseDeploymentCLITests",
            dependencies: [
                "EnterpriseDeploymentCLI",
                "EnterpriseDeploymentCore"
            ],
            path: "Tests/CLI"
        )
    ]
) 