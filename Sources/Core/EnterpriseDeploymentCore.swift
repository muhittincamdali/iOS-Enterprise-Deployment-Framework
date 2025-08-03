//
//  EnterpriseDeploymentCore.swift
//  iOS Enterprise Deployment Framework
//
//  Created by Muhittin Camdali
//  Copyright © 2023-2024 Muhittin Camdali. All rights reserved.
//

import Foundation
import Crypto
import Logging
import NIO
import NIOSSL

/// Main entry point for the iOS Enterprise Deployment Framework.
///
/// This class provides comprehensive enterprise deployment capabilities including
/// MDM integration, app distribution, compliance monitoring, and analytics.
///
/// ## Usage
///
/// ```swift
/// let configuration = EnterpriseDeploymentConfiguration(
///     mdmServerURL: "https://mdm.company.com",
///     appStoreURL: "https://enterprise.company.com/apps",
///     organizationID: "company-org-id"
/// )
///
/// let deployment = EnterpriseDeployment(configuration: configuration)
/// try await deployment.deploy(app: appBundle)
/// ```
///
/// ## Thread Safety
///
/// This class is thread-safe and can be used from multiple threads concurrently.
public class EnterpriseDeployment {
    
    // MARK: - Properties
    
    /// The configuration used for enterprise deployment.
    public let configuration: EnterpriseDeploymentConfiguration
    
    /// The MDM integration service.
    public let mdmService: MDMService
    
    /// The app distribution service.
    public let distributionService: AppDistributionService
    
    /// The compliance monitoring service.
    public let complianceService: ComplianceService
    
    /// The analytics service.
    public let analyticsService: AnalyticsService
    
    /// Logger for deployment operations.
    private let logger = Logger(label: "com.muhittincamdali.enterprise-deployment")
    
    // MARK: - Initialization
    
    /// Creates a new enterprise deployment instance.
    ///
    /// - Parameter configuration: The configuration for enterprise deployment.
    /// - Throws: `EnterpriseDeploymentError.invalidConfiguration` if configuration is invalid.
    public init(configuration: EnterpriseDeploymentConfiguration) throws {
        self.configuration = configuration
        
        // Validate configuration
        try Self.validateConfiguration(configuration)
        
        // Initialize services
        self.mdmService = MDMService(configuration: configuration.mdmConfiguration)
        self.distributionService = AppDistributionService(configuration: configuration.distributionConfiguration)
        self.complianceService = ComplianceService(configuration: configuration.complianceConfiguration)
        self.analyticsService = AnalyticsService(configuration: configuration.analyticsConfiguration)
        
        logger.info("Enterprise Deployment Framework initialized with configuration: \(configuration)")
    }
    
    // MARK: - Public Methods
    
    /// Deploys an app bundle to enterprise devices.
    ///
    /// This method handles the complete deployment process including:
    /// - App validation and signing
    /// - MDM integration for device management
    /// - Distribution through enterprise app store
    /// - Compliance monitoring and reporting
    /// - Analytics tracking
    ///
    /// - Parameters:
    ///   - app: The app bundle to deploy
    ///   - devices: Optional list of target devices. If nil, deploys to all enrolled devices.
    ///   - options: Deployment options for customizing the deployment process
    /// - Throws: `DeploymentError` if deployment fails
    /// - Returns: Deployment result with status and metadata
    public func deploy(
        app: AppBundle,
        to devices: [Device]? = nil,
        options: DeploymentOptions = DeploymentOptions()
    ) async throws -> DeploymentResult {
        
        logger.info("Starting deployment for app: \(app.identifier)")
        
        // Validate app bundle
        try await validateAppBundle(app)
        
        // Check compliance requirements
        try await checkComplianceRequirements(for: app)
        
        // Sign the app if needed
        let signedApp = try await signAppIfNeeded(app)
        
        // Upload to enterprise app store
        let uploadResult = try await distributionService.uploadApp(signedApp)
        
        // Deploy to devices
        let deploymentResult = try await deployToDevices(signedApp, devices: devices, options: options)
        
        // Track analytics
        try await analyticsService.trackDeployment(deploymentResult)
        
        // Generate compliance report
        let complianceReport = try await complianceService.generateDeploymentReport(deploymentResult)
        
        logger.info("Deployment completed successfully for app: \(app.identifier)")
        
        return DeploymentResult(
            status: .success,
            appIdentifier: app.identifier,
            deploymentID: deploymentResult.deploymentID,
            deployedDevices: deploymentResult.deployedDevices,
            failedDevices: deploymentResult.failedDevices,
            complianceReport: complianceReport,
            analytics: deploymentResult.analytics,
            timestamp: Date()
        )
    }
    
    /// Enrolls a device in the enterprise MDM system.
    ///
    /// - Parameters:
    ///   - device: The device to enroll
    ///   - enrollmentToken: The enrollment token for the device
    /// - Throws: `MDMError` if enrollment fails
    /// - Returns: Enrollment result with device information
    public func enrollDevice(_ device: Device, with enrollmentToken: String) async throws -> EnrollmentResult {
        logger.info("Enrolling device: \(device.identifier)")
        
        let result = try await mdmService.enrollDevice(device, with: enrollmentToken)
        
        logger.info("Device enrolled successfully: \(device.identifier)")
        
        return result
    }
    
    /// Removes a device from the enterprise MDM system.
    ///
    /// - Parameter device: The device to remove
    /// - Throws: `MDMError` if removal fails
    public func removeDevice(_ device: Device) async throws {
        logger.info("Removing device: \(device.identifier)")
        
        try await mdmService.removeDevice(device)
        
        logger.info("Device removed successfully: \(device.identifier)")
    }
    
    /// Gets a list of all enrolled devices.
    ///
    /// - Throws: `MDMError` if retrieval fails
    /// - Returns: List of enrolled devices
    public func getEnrolledDevices() async throws -> [Device] {
        return try await mdmService.getEnrolledDevices()
    }
    
    /// Gets deployment analytics for a specific time period.
    ///
    /// - Parameters:
    ///   - startDate: Start date for analytics period
    ///   - endDate: End date for analytics period
    /// - Throws: `AnalyticsError` if analytics retrieval fails
    /// - Returns: Analytics data for the specified period
    public func getAnalytics(from startDate: Date, to endDate: Date) async throws -> AnalyticsData {
        return try await analyticsService.getAnalytics(from: startDate, to: endDate)
    }
    
    /// Generates a compliance report for the enterprise.
    ///
    /// - Parameters:
    ///   - period: The time period for the report
    ///   - includeAuditLogs: Whether to include audit logs in the report
    /// - Throws: `ComplianceError` if report generation fails
    /// - Returns: Compliance report for the specified period
    public func generateComplianceReport(
        for period: ReportPeriod,
        includeAuditLogs: Bool = true
    ) async throws -> ComplianceReport {
        return try await complianceService.generateReport(for: period, includeAuditLogs: includeAuditLogs)
    }
    
    // MARK: - Private Methods
    
    /// Validates the enterprise deployment configuration.
    ///
    /// - Parameter configuration: The configuration to validate
    /// - Throws: `EnterpriseDeploymentError.invalidConfiguration` if configuration is invalid
    private static func validateConfiguration(_ configuration: EnterpriseDeploymentConfiguration) throws {
        guard !configuration.mdmServerURL.isEmpty else {
            throw EnterpriseDeploymentError.invalidConfiguration("MDM server URL cannot be empty")
        }
        
        guard !configuration.appStoreURL.isEmpty else {
            throw EnterpriseDeploymentError.invalidConfiguration("App store URL cannot be empty")
        }
        
        guard !configuration.organizationID.isEmpty else {
            throw EnterpriseDeploymentError.invalidConfiguration("Organization ID cannot be empty")
        }
    }
    
    /// Validates an app bundle before deployment.
    ///
    /// - Parameter app: The app bundle to validate
    /// - Throws: `DeploymentError` if validation fails
    private func validateAppBundle(_ app: AppBundle) async throws {
        guard !app.identifier.isEmpty else {
            throw DeploymentError.invalidAppBundle("App identifier cannot be empty")
        }
        
        guard app.version != nil else {
            throw DeploymentError.invalidAppBundle("App version cannot be nil")
        }
        
        guard app.bundleURL != nil else {
            throw DeploymentError.invalidAppBundle("App bundle URL cannot be nil")
        }
        
        // Additional validation can be added here
        logger.debug("App bundle validation passed for: \(app.identifier)")
    }
    
    /// Checks compliance requirements for an app.
    ///
    /// - Parameter app: The app to check compliance for
    /// - Throws: `ComplianceError` if compliance check fails
    private func checkComplianceRequirements(for app: AppBundle) async throws {
        let requirements = try await complianceService.getComplianceRequirements(for: app)
        
        guard requirements.isCompliant else {
            throw ComplianceError.nonCompliantApp(requirements.violations)
        }
        
        logger.debug("Compliance check passed for app: \(app.identifier)")
    }
    
    /// Signs an app if signing is required.
    ///
    /// - Parameter app: The app to sign
    /// - Throws: `DeploymentError` if signing fails
    /// - Returns: The signed app bundle
    private func signAppIfNeeded(_ app: AppBundle) async throws -> AppBundle {
        guard configuration.distributionConfiguration.requiresSigning else {
            return app
        }
        
        logger.debug("Signing app: \(app.identifier)")
        
        let signedApp = try await distributionService.signApp(app)
        
        logger.debug("App signed successfully: \(app.identifier)")
        
        return signedApp
    }
    
    /// Deploys an app to target devices.
    ///
    /// - Parameters:
    ///   - app: The app to deploy
    ///   - devices: Target devices, or nil for all enrolled devices
    ///   - options: Deployment options
    /// - Throws: `DeploymentError` if deployment fails
    /// - Returns: Deployment result with device information
    private func deployToDevices(
        _ app: AppBundle,
        devices: [Device]?,
        options: DeploymentOptions
    ) async throws -> DeviceDeploymentResult {
        
        let targetDevices = devices ?? try await mdmService.getEnrolledDevices()
        
        logger.info("Deploying app \(app.identifier) to \(targetDevices.count) devices")
        
        var deployedDevices: [Device] = []
        var failedDevices: [DeviceDeploymentFailure] = []
        
        for device in targetDevices {
            do {
                try await mdmService.installApp(app, on: device)
                deployedDevices.append(device)
                logger.debug("App deployed successfully to device: \(device.identifier)")
            } catch {
                let failure = DeviceDeploymentFailure(device: device, error: error)
                failedDevices.append(failure)
                logger.error("Failed to deploy app to device \(device.identifier): \(error)")
            }
        }
        
        return DeviceDeploymentResult(
            deploymentID: UUID().uuidString,
            deployedDevices: deployedDevices,
            failedDevices: failedDevices,
            analytics: AnalyticsData(
                totalDevices: targetDevices.count,
                successfulDeployments: deployedDevices.count,
                failedDeployments: failedDevices.count,
                deploymentTime: Date()
            )
        )
    }
}

// MARK: - Supporting Types

/// Configuration for enterprise deployment.
public struct EnterpriseDeploymentConfiguration {
    
    /// MDM configuration for device management.
    public let mdmConfiguration: MDMConfiguration
    
    /// Distribution configuration for app deployment.
    public let distributionConfiguration: DistributionConfiguration
    
    /// Compliance configuration for regulatory requirements.
    public let complianceConfiguration: ComplianceConfiguration
    
    /// Analytics configuration for tracking and reporting.
    public let analyticsConfiguration: AnalyticsConfiguration
    
    /// MDM server URL.
    public var mdmServerURL: String { mdmConfiguration.serverURL }
    
    /// Enterprise app store URL.
    public var appStoreURL: String { distributionConfiguration.appStoreURL }
    
    /// Organization identifier.
    public var organizationID: String { mdmConfiguration.organizationID }
    
    /// Creates a new enterprise deployment configuration.
    ///
    /// - Parameters:
    ///   - mdmConfiguration: MDM configuration
    ///   - distributionConfiguration: Distribution configuration
    ///   - complianceConfiguration: Compliance configuration
    ///   - analyticsConfiguration: Analytics configuration
    public init(
        mdmConfiguration: MDMConfiguration,
        distributionConfiguration: DistributionConfiguration,
        complianceConfiguration: ComplianceConfiguration,
        analyticsConfiguration: AnalyticsConfiguration
    ) {
        self.mdmConfiguration = mdmConfiguration
        self.distributionConfiguration = distributionConfiguration
        self.complianceConfiguration = complianceConfiguration
        self.analyticsConfiguration = analyticsConfiguration
    }
    
    /// Creates a new enterprise deployment configuration with default settings.
    ///
    /// - Parameters:
    ///   - mdmServerURL: MDM server URL
    ///   - appStoreURL: Enterprise app store URL
    ///   - organizationID: Organization identifier
    public init(
        mdmServerURL: String,
        appStoreURL: String,
        organizationID: String
    ) {
        self.mdmConfiguration = MDMConfiguration(
            serverURL: mdmServerURL,
            organizationID: organizationID
        )
        
        self.distributionConfiguration = DistributionConfiguration(
            appStoreURL: appStoreURL
        )
        
        self.complianceConfiguration = ComplianceConfiguration()
        
        self.analyticsConfiguration = AnalyticsConfiguration()
    }
}

/// Options for customizing deployment behavior.
public struct DeploymentOptions {
    
    /// Whether to force deployment even if app is already installed.
    public let forceDeployment: Bool
    
    /// Whether to rollback on deployment failure.
    public let rollbackOnFailure: Bool
    
    /// Maximum number of concurrent deployments.
    public let maxConcurrentDeployments: Int
    
    /// Timeout for deployment operations.
    public let deploymentTimeout: TimeInterval
    
    /// Creates new deployment options.
    ///
    /// - Parameters:
    ///   - forceDeployment: Whether to force deployment
    ///   - rollbackOnFailure: Whether to rollback on failure
    ///   - maxConcurrentDeployments: Maximum concurrent deployments
    ///   - deploymentTimeout: Deployment timeout
    public init(
        forceDeployment: Bool = false,
        rollbackOnFailure: Bool = true,
        maxConcurrentDeployments: Int = 10,
        deploymentTimeout: TimeInterval = 300.0
    ) {
        self.forceDeployment = forceDeployment
        self.rollbackOnFailure = rollbackOnFailure
        self.maxConcurrentDeployments = maxConcurrentDeployments
        self.deploymentTimeout = deploymentTimeout
    }
}

/// Result of a deployment operation.
public struct DeploymentResult {
    
    /// The status of the deployment.
    public let status: DeploymentStatus
    
    /// The identifier of the deployed app.
    public let appIdentifier: String
    
    /// The unique deployment identifier.
    public let deploymentID: String
    
    /// List of successfully deployed devices.
    public let deployedDevices: [Device]
    
    /// List of devices where deployment failed.
    public let failedDevices: [DeviceDeploymentFailure]
    
    /// Compliance report for the deployment.
    public let complianceReport: ComplianceReport?
    
    /// Analytics data for the deployment.
    public let analytics: AnalyticsData?
    
    /// Timestamp of the deployment.
    public let timestamp: Date
    
    /// Creates a new deployment result.
    ///
    /// - Parameters:
    ///   - status: Deployment status
    ///   - appIdentifier: App identifier
    ///   - deploymentID: Deployment identifier
    ///   - deployedDevices: Successfully deployed devices
    ///   - failedDevices: Failed device deployments
    ///   - complianceReport: Compliance report
    ///   - analytics: Analytics data
    ///   - timestamp: Deployment timestamp
    public init(
        status: DeploymentStatus,
        appIdentifier: String,
        deploymentID: String,
        deployedDevices: [Device],
        failedDevices: [DeviceDeploymentFailure],
        complianceReport: ComplianceReport?,
        analytics: AnalyticsData?,
        timestamp: Date
    ) {
        self.status = status
        self.appIdentifier = appIdentifier
        self.deploymentID = deploymentID
        self.deployedDevices = deployedDevices
        self.failedDevices = failedDevices
        self.complianceReport = complianceReport
        self.analytics = analytics
        self.timestamp = timestamp
    }
}

/// Status of a deployment operation.
public enum DeploymentStatus {
    case success
    case partialSuccess
    case failure
    case cancelled
}

/// Result of device enrollment.
public struct EnrollmentResult {
    
    /// The enrolled device.
    public let device: Device
    
    /// Enrollment status.
    public let status: EnrollmentStatus
    
    /// Enrollment timestamp.
    public let timestamp: Date
    
    /// Creates a new enrollment result.
    ///
    /// - Parameters:
    ///   - device: Enrolled device
    ///   - status: Enrollment status
    ///   - timestamp: Enrollment timestamp
    public init(device: Device, status: EnrollmentStatus, timestamp: Date) {
        self.device = device
        self.status = status
        self.timestamp = timestamp
    }
}

/// Status of device enrollment.
public enum EnrollmentStatus {
    case enrolled
    case pending
    case failed
}

/// Result of device deployment.
public struct DeviceDeploymentResult {
    
    /// Unique deployment identifier.
    public let deploymentID: String
    
    /// Successfully deployed devices.
    public let deployedDevices: [Device]
    
    /// Failed device deployments.
    public let failedDevices: [DeviceDeploymentFailure]
    
    /// Analytics data.
    public let analytics: AnalyticsData
    
    /// Creates a new device deployment result.
    ///
    /// - Parameters:
    ///   - deploymentID: Deployment identifier
    ///   - deployedDevices: Successfully deployed devices
    ///   - failedDevices: Failed device deployments
    ///   - analytics: Analytics data
    public init(
        deploymentID: String,
        deployedDevices: [Device],
        failedDevices: [DeviceDeploymentFailure],
        analytics: AnalyticsData
    ) {
        self.deploymentID = deploymentID
        self.deployedDevices = deployedDevices
        self.failedDevices = failedDevices
        self.analytics = analytics
    }
}

/// Failure information for device deployment.
public struct DeviceDeploymentFailure {
    
    /// The device that failed deployment.
    public let device: Device
    
    /// The error that caused the failure.
    public let error: Error
    
    /// Creates a new device deployment failure.
    ///
    /// - Parameters:
    ///   - device: Failed device
    ///   - error: Failure error
    public init(device: Device, error: Error) {
        self.device = device
        self.error = error
    }
}

// MARK: - Error Types

/// Errors that can occur during enterprise deployment operations.
public enum EnterpriseDeploymentError: Error, LocalizedError {
    case invalidConfiguration(String)
    case initializationFailed(String)
    case serviceUnavailable(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidConfiguration(let message):
            return "Invalid configuration: \(message)"
        case .initializationFailed(let message):
            return "Initialization failed: \(message)"
        case .serviceUnavailable(let message):
            return "Service unavailable: \(message)"
        }
    }
}

/// Errors that can occur during deployment operations.
public enum DeploymentError: Error, LocalizedError {
    case invalidAppBundle(String)
    case signingFailed(String)
    case uploadFailed(String)
    case deploymentFailed(String)
    case timeout(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidAppBundle(let message):
            return "Invalid app bundle: \(message)"
        case .signingFailed(let message):
            return "App signing failed: \(message)"
        case .uploadFailed(let message):
            return "App upload failed: \(message)"
        case .deploymentFailed(let message):
            return "Deployment failed: \(message)"
        case .timeout(let message):
            return "Deployment timeout: \(message)"
        }
    }
} 