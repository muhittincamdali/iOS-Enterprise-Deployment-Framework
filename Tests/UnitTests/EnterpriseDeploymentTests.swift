//
//  EnterpriseDeploymentTests.swift
//  iOS Enterprise Deployment Framework Tests
//
//  Created by Muhittin Camdali
//  Copyright © 2023-2024 Muhittin Camdali. All rights reserved.
//

import XCTest
import EnterpriseDeploymentFramework
@testable import EnterpriseDeploymentCore

final class EnterpriseDeploymentTests: XCTestCase {
    
    var deploymentManager: EnterpriseDeploymentManager!
    var mockMDMService: MockMDMService!
    var mockDistributionService: MockAppDistributionService!
    var mockComplianceService: MockComplianceService!
    var mockAnalyticsService: MockAnalyticsService!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        // Initialize mock services
        mockMDMService = MockMDMService()
        mockDistributionService = MockAppDistributionService()
        mockComplianceService = MockComplianceService()
        mockAnalyticsService = MockAnalyticsService()
        
        // Initialize deployment manager with mocks
        deploymentManager = EnterpriseDeploymentManager(
            mdmService: mockMDMService,
            distributionService: mockDistributionService,
            complianceService: mockComplianceService,
            analyticsService: mockAnalyticsService
        )
    }
    
    override func tearDownWithError() throws {
        deploymentManager = nil
        mockMDMService = nil
        mockDistributionService = nil
        mockComplianceService = nil
        mockAnalyticsService = nil
        try super.tearDownWithError()
    }
    
    // MARK: - Deployment Tests
    
    func testSuccessfulDeployment() async throws {
        // Given
        let deployment = createTestDeployment()
        mockComplianceService.shouldSucceed = true
        mockDistributionService.shouldSucceed = true
        mockAnalyticsService.shouldSucceed = true
        
        // When
        let result = try await deploymentManager.deploy(deployment)
        
        // Then
        XCTAssertEqual(result.status, .success)
        XCTAssertEqual(result.deployedDevices.count, 5)
        XCTAssertEqual(result.failedDevices.count, 0)
        XCTAssertNotNil(result.deploymentID)
    }
    
    func testDeploymentWithComplianceFailure() async throws {
        // Given
        let deployment = createTestDeployment()
        mockComplianceService.shouldSucceed = false
        mockComplianceService.error = EnterpriseDeploymentError.complianceViolation("GDPR violation")
        
        // When & Then
        do {
            _ = try await deploymentManager.deploy(deployment)
            XCTFail("Expected deployment to fail due to compliance violation")
        } catch EnterpriseDeploymentError.complianceViolation {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testDeploymentWithDistributionFailure() async throws {
        // Given
        let deployment = createTestDeployment()
        mockComplianceService.shouldSucceed = true
        mockDistributionService.shouldSucceed = false
        mockDistributionService.error = EnterpriseDeploymentError.distributionFailed("Network error")
        
        // When & Then
        do {
            _ = try await deploymentManager.deploy(deployment)
            XCTFail("Expected deployment to fail due to distribution failure")
        } catch EnterpriseDeploymentError.distributionFailed {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testDeploymentWithAnalyticsFailure() async throws {
        // Given
        let deployment = createTestDeployment()
        mockComplianceService.shouldSucceed = true
        mockDistributionService.shouldSucceed = true
        mockAnalyticsService.shouldSucceed = false
        mockAnalyticsService.error = EnterpriseDeploymentError.analyticsError("Analytics service unavailable")
        
        // When
        let result = try await deploymentManager.deploy(deployment)
        
        // Then - Deployment should succeed even if analytics fails
        XCTAssertEqual(result.status, .success)
        XCTAssertEqual(result.deployedDevices.count, 5)
    }
    
    // MARK: - Configuration Tests
    
    func testValidConfiguration() throws {
        // Given
        let config = createValidConfiguration()
        
        // When & Then
        XCTAssertNoThrow(try EnterpriseDeployment(configuration: config))
    }
    
    func testInvalidConfiguration() throws {
        // Given
        let config = createInvalidConfiguration()
        
        // When & Then
        do {
            _ = try EnterpriseDeployment(configuration: config)
            XCTFail("Expected configuration validation to fail")
        } catch EnterpriseDeploymentError.invalidConfiguration {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testConfigurationValidation() throws {
        // Given
        let config = createTestConfiguration()
        
        // When
        let isValid = try EnterpriseDeployment.validateConfiguration(config)
        
        // Then
        XCTAssertTrue(isValid)
    }
    
    // MARK: - MDM Service Tests
    
    func testDeviceEnrollment() async throws {
        // Given
        let device = createTestDevice()
        mockMDMService.shouldSucceed = true
        
        // When
        let result = try await mockMDMService.enrollDevice(device)
        
        // Then
        XCTAssertEqual(result.status, .success)
        XCTAssertNotNil(result.enrollmentID)
        XCTAssertEqual(result.deviceID, device.identifier)
    }
    
    func testDeviceEnrollmentFailure() async throws {
        // Given
        let device = createTestDevice()
        mockMDMService.shouldSucceed = false
        mockMDMService.error = EnterpriseDeploymentError.mdmConnectionFailed("Connection timeout")
        
        // When & Then
        do {
            _ = try await mockMDMService.enrollDevice(device)
            XCTFail("Expected enrollment to fail")
        } catch EnterpriseDeploymentError.mdmConnectionFailed {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testDeviceUnenrollment() async throws {
        // Given
        let device = createTestDevice()
        mockMDMService.shouldSucceed = true
        
        // When
        let result = try await mockMDMService.unenrollDevice(device)
        
        // Then
        XCTAssertEqual(result.status, .success)
        XCTAssertEqual(result.deviceID, device.identifier)
    }
    
    // MARK: - Distribution Service Tests
    
    func testAppStoreDistribution() async throws {
        // Given
        let appBundle = createTestAppBundle()
        mockDistributionService.shouldSucceed = true
        
        // When
        let result = try await mockDistributionService.uploadToAppStore(appBundle)
        
        // Then
        XCTAssertEqual(result.status, .success)
        XCTAssertNotNil(result.appStoreID)
        XCTAssertEqual(result.appID, appBundle.identifier)
    }
    
    func testTestFlightDistribution() async throws {
        // Given
        let appBundle = createTestAppBundle()
        mockDistributionService.shouldSucceed = true
        
        // When
        let result = try await mockDistributionService.uploadToTestFlight(appBundle)
        
        // Then
        XCTAssertEqual(result.status, .success)
        XCTAssertNotNil(result.testFlightID)
        XCTAssertEqual(result.appID, appBundle.identifier)
    }
    
    func testEnterpriseDistribution() async throws {
        // Given
        let appBundle = createTestAppBundle()
        let channel = DistributionChannel.enterprise
        mockDistributionService.shouldSucceed = true
        
        // When
        let result = try await mockDistributionService.distribute(appBundle, to: channel)
        
        // Then
        XCTAssertEqual(result.status, .success)
        XCTAssertEqual(result.deployedDevices.count, 10)
        XCTAssertEqual(result.channel, channel)
    }
    
    // MARK: - Compliance Service Tests
    
    func testComplianceCheck() async throws {
        // Given
        let appBundle = createTestAppBundle()
        mockComplianceService.shouldSucceed = true
        
        // When
        let report = try await mockComplianceService.checkCompliance(for: appBundle)
        
        // Then
        XCTAssertTrue(report.isCompliant)
        XCTAssertEqual(report.complianceLevel, .high)
        XCTAssertEqual(report.violations.count, 0)
    }
    
    func testComplianceViolation() async throws {
        // Given
        let appBundle = createTestAppBundle()
        mockComplianceService.shouldSucceed = false
        mockComplianceService.violations = ["GDPR violation", "HIPAA violation"]
        
        // When
        let report = try await mockComplianceService.checkCompliance(for: appBundle)
        
        // Then
        XCTAssertFalse(report.isCompliant)
        XCTAssertEqual(report.complianceLevel, .low)
        XCTAssertEqual(report.violations.count, 2)
    }
    
    func testSecurityValidation() async throws {
        // Given
        mockComplianceService.shouldSucceed = true
        
        // When
        let result = try await mockComplianceService.validateSecurityRequirements()
        
        // Then
        XCTAssertTrue(result.isValid)
        XCTAssertEqual(result.securityLevel, .high)
        XCTAssertEqual(result.issues.count, 0)
    }
    
    // MARK: - Analytics Service Tests
    
    func testDeploymentTracking() async throws {
        // Given
        let deployment = createTestDeployment()
        mockAnalyticsService.shouldSucceed = true
        
        // When
        try await mockAnalyticsService.trackDeployment(deployment)
        
        // Then
        XCTAssertTrue(mockAnalyticsService.trackDeploymentCalled)
        XCTAssertEqual(mockAnalyticsService.trackedDeployment?.appId, deployment.appId)
    }
    
    func testDeviceEnrollmentTracking() async throws {
        // Given
        let device = createTestDevice()
        mockAnalyticsService.shouldSucceed = true
        
        // When
        try await mockAnalyticsService.trackDeviceEnrollment(device)
        
        // Then
        XCTAssertTrue(mockAnalyticsService.trackDeviceEnrollmentCalled)
        XCTAssertEqual(mockAnalyticsService.trackedDevice?.identifier, device.identifier)
    }
    
    func testAnalyticsReportGeneration() async throws {
        // Given
        mockAnalyticsService.shouldSucceed = true
        
        // When
        let report = try await mockAnalyticsService.generateAnalyticsReport()
        
        // Then
        XCTAssertNotNil(report)
        XCTAssertGreaterThan(report.totalDeployments, 0)
        XCTAssertGreaterThan(report.successRate, 0.0)
    }
    
    // MARK: - Error Handling Tests
    
    func testNetworkErrorHandling() async throws {
        // Given
        let deployment = createTestDeployment()
        mockDistributionService.shouldSucceed = false
        mockDistributionService.error = EnterpriseDeploymentError.networkError("Connection failed")
        
        // When & Then
        do {
            _ = try await deploymentManager.deploy(deployment)
            XCTFail("Expected deployment to fail due to network error")
        } catch EnterpriseDeploymentError.networkError {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testAuthenticationErrorHandling() async throws {
        // Given
        let deployment = createTestDeployment()
        mockDistributionService.shouldSucceed = false
        mockDistributionService.error = EnterpriseDeploymentError.authenticationFailed("Invalid credentials")
        
        // When & Then
        do {
            _ = try await deploymentManager.deploy(deployment)
            XCTFail("Expected deployment to fail due to authentication error")
        } catch EnterpriseDeploymentError.authenticationFailed {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    func testTimeoutErrorHandling() async throws {
        // Given
        let deployment = createTestDeployment()
        mockDistributionService.shouldSucceed = false
        mockDistributionService.error = EnterpriseDeploymentError.timeoutError("Operation timed out")
        
        // When & Then
        do {
            _ = try await deploymentManager.deploy(deployment)
            XCTFail("Expected deployment to fail due to timeout")
        } catch EnterpriseDeploymentError.timeoutError {
            // Expected error
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
    
    // MARK: - Performance Tests
    
    func testDeploymentPerformance() async throws {
        // Given
        let deployment = createTestDeployment()
        mockComplianceService.shouldSucceed = true
        mockDistributionService.shouldSucceed = true
        mockAnalyticsService.shouldSucceed = true
        
        // When
        let startTime = Date()
        let result = try await deploymentManager.deploy(deployment)
        let endTime = Date()
        
        // Then
        let duration = endTime.timeIntervalSince(startTime)
        XCTAssertLessThan(duration, 5.0) // Should complete within 5 seconds
        XCTAssertEqual(result.status, .success)
    }
    
    func testConcurrentDeployments() async throws {
        // Given
        let deployments = (0..<5).map { _ in createTestDeployment() }
        mockComplianceService.shouldSucceed = true
        mockDistributionService.shouldSucceed = true
        mockAnalyticsService.shouldSucceed = true
        
        // When
        let startTime = Date()
        let results = try await withThrowingTaskGroup(of: DeploymentResult.self) { group in
            for deployment in deployments {
                group.addTask {
                    return try await self.deploymentManager.deploy(deployment)
                }
            }
            
            var results: [DeploymentResult] = []
            for try await result in group {
                results.append(result)
            }
            return results
        }
        let endTime = Date()
        
        // Then
        let duration = endTime.timeIntervalSince(startTime)
        XCTAssertLessThan(duration, 10.0) // Should complete within 10 seconds
        XCTAssertEqual(results.count, 5)
        
        for result in results {
            XCTAssertEqual(result.status, .success)
        }
    }
    
    // MARK: - Helper Methods
    
    private func createTestDeployment() -> Deployment {
        return Deployment(
            appId: "com.test.app",
            version: "1.0.0",
            buildNumber: "100",
            channel: .testFlight,
            environment: .staging,
            configuration: [:],
            metadata: DeploymentMetadata()
        )
    }
    
    private func createValidConfiguration() -> EnterpriseDeploymentConfiguration {
        let mdmConfig = MDMConfiguration(
            serverURL: URL(string: "https://mdm.test.com")!,
            organizationID: "test-org",
            certificatePath: "/test/cert.p12",
            privateKeyPath: "/test/key.pem",
            enrollmentURL: URL(string: "https://enroll.test.com")!
        )
        
        let distributionConfig = DistributionConfiguration(
            appStoreConnectAPIKey: "test-api-key",
            testFlightAPIKey: "test-testflight-key",
            enterpriseDistributionURL: URL(string: "https://enterprise.test.com/apps")!,
            codeSigningIdentity: "iPhone Distribution: Test Company",
            provisioningProfile: "Test_Enterprise_Profile"
        )
        
        let complianceConfig = ComplianceConfiguration(
            gdprCompliance: true,
            hipaaCompliance: false,
            soxCompliance: false,
            auditLogging: true,
            dataRetentionPolicy: DataRetentionPolicy(
                retentionPeriod: 90 * 24 * 60 * 60,
                encryptionRequired: true,
                accessLogging: true
            )
        )
        
        let analyticsConfig = AnalyticsConfiguration(
            analyticsEnabled: true,
            trackingEndpoint: URL(string: "https://analytics.test.com")!,
            apiKey: "test-analytics-key",
            dataRetentionDays: 90,
            privacyCompliance: true
        )
        
        return EnterpriseDeploymentConfiguration(
            mdmConfiguration: mdmConfig,
            distributionConfiguration: distributionConfig,
            complianceConfiguration: complianceConfig,
            analyticsConfiguration: analyticsConfig
        )
    }
    
    private func createInvalidConfiguration() -> EnterpriseDeploymentConfiguration {
        let mdmConfig = MDMConfiguration(
            serverURL: URL(string: "https://mdm.test.com")!,
            organizationID: "", // Invalid empty organization ID
            certificatePath: "/test/cert.p12",
            privateKeyPath: "/test/key.pem",
            enrollmentURL: URL(string: "https://enroll.test.com")!
        )
        
        let distributionConfig = DistributionConfiguration(
            appStoreConnectAPIKey: "", // Invalid empty API key
            testFlightAPIKey: "test-testflight-key",
            enterpriseDistributionURL: URL(string: "https://enterprise.test.com/apps")!,
            codeSigningIdentity: "iPhone Distribution: Test Company",
            provisioningProfile: "Test_Enterprise_Profile"
        )
        
        let complianceConfig = ComplianceConfiguration(
            gdprCompliance: true,
            hipaaCompliance: false,
            soxCompliance: false,
            auditLogging: true,
            dataRetentionPolicy: DataRetentionPolicy(
                retentionPeriod: 90 * 24 * 60 * 60,
                encryptionRequired: true,
                accessLogging: true
            )
        )
        
        let analyticsConfig = AnalyticsConfiguration(
            analyticsEnabled: true,
            trackingEndpoint: URL(string: "https://analytics.test.com")!,
            apiKey: "test-analytics-key",
            dataRetentionDays: 90,
            privacyCompliance: true
        )
        
        return EnterpriseDeploymentConfiguration(
            mdmConfiguration: mdmConfig,
            distributionConfiguration: distributionConfig,
            complianceConfiguration: complianceConfig,
            analyticsConfiguration: analyticsConfig
        )
    }
    
    private func createTestConfiguration() -> EnterpriseDeploymentConfiguration {
        return createValidConfiguration()
    }
    
    private func createTestDevice() -> Device {
        return Device(
            identifier: "test-device-uuid",
            name: "Test iPhone",
            model: "iPhone14,2",
            osVersion: "16.0",
            deviceInfo: DeviceInfo()
        )
    }
    
    private func createTestAppBundle() -> AppBundle {
        return AppBundle(
            identifier: "com.test.app",
            version: "1.0.0",
            bundleURL: URL(string: "https://test.com/app.ipa")!,
            metadata: AppMetadata(
                name: "Test App",
                description: "Test application",
                category: "Productivity",
                size: 50_000_000
            )
        )
    }
}

// MARK: - Mock Services

class MockMDMService: MDMService {
    var shouldSucceed = true
    var error: Error?
    
    override func enrollDevice(_ device: Device) async throws -> EnrollmentResult {
        if shouldSucceed {
            return EnrollmentResult(
                status: .success,
                enrollmentID: "enrollment-123",
                deviceID: device.identifier,
                timestamp: Date()
            )
        } else {
            throw error ?? EnterpriseDeploymentError.mdmConnectionFailed("Mock error")
        }
    }
    
    override func unenrollDevice(_ device: Device) async throws -> UnenrollmentResult {
        if shouldSucceed {
            return UnenrollmentResult(
                status: .success,
                deviceID: device.identifier,
                timestamp: Date()
            )
        } else {
            throw error ?? EnterpriseDeploymentError.mdmConnectionFailed("Mock error")
        }
    }
}

class MockAppDistributionService: AppDistributionService {
    var shouldSucceed = true
    var error: Error?
    
    override func distribute(_ app: AppBundle, to channel: DistributionChannel) async throws -> DistributionResult {
        if shouldSucceed {
            return DistributionResult(
                status: .success,
                deployedDevices: createMockDevices(count: 10),
                failedDevices: [],
                channel: channel,
                timestamp: Date()
            )
        } else {
            throw error ?? EnterpriseDeploymentError.distributionFailed("Mock error")
        }
    }
    
    override func uploadToAppStore(_ app: AppBundle) async throws -> AppStoreResult {
        if shouldSucceed {
            return AppStoreResult(
                status: .success,
                appStoreID: "app-store-123",
                appID: app.identifier,
                timestamp: Date()
            )
        } else {
            throw error ?? EnterpriseDeploymentError.distributionFailed("Mock error")
        }
    }
    
    override func uploadToTestFlight(_ app: AppBundle) async throws -> TestFlightResult {
        if shouldSucceed {
            return TestFlightResult(
                status: .success,
                testFlightID: "testflight-123",
                appID: app.identifier,
                timestamp: Date()
            )
        } else {
            throw error ?? EnterpriseDeploymentError.distributionFailed("Mock error")
        }
    }
    
    private func createMockDevices(count: Int) -> [Device] {
        return (0..<count).map { index in
            Device(
                identifier: "device-\(index)",
                name: "Device \(index)",
                model: "iPhone",
                osVersion: "16.0",
                deviceInfo: DeviceInfo()
            )
        }
    }
}

class MockComplianceService: ComplianceService {
    var shouldSucceed = true
    var error: Error?
    var violations: [String] = []
    
    override func checkCompliance(for app: AppBundle) async throws -> ComplianceReport {
        if shouldSucceed {
            return ComplianceReport(
                isCompliant: true,
                complianceLevel: .high,
                violations: [],
                timestamp: Date()
            )
        } else {
            return ComplianceReport(
                isCompliant: false,
                complianceLevel: .low,
                violations: violations,
                timestamp: Date()
            )
        }
    }
    
    override func validateSecurityRequirements() async throws -> SecurityValidationResult {
        if shouldSucceed {
            return SecurityValidationResult(
                isValid: true,
                securityLevel: .high,
                issues: [],
                timestamp: Date()
            )
        } else {
            throw error ?? EnterpriseDeploymentError.complianceViolation("Mock violation")
        }
    }
}

class MockAnalyticsService: AnalyticsService {
    var shouldSucceed = true
    var error: Error?
    var trackDeploymentCalled = false
    var trackDeviceEnrollmentCalled = false
    var trackedDeployment: Deployment?
    var trackedDevice: Device?
    
    override func trackDeployment(_ deployment: Deployment) async throws {
        if shouldSucceed {
            trackDeploymentCalled = true
            trackedDeployment = deployment
        } else {
            throw error ?? EnterpriseDeploymentError.analyticsError("Mock error")
        }
    }
    
    override func trackDeviceEnrollment(_ device: Device) async throws {
        if shouldSucceed {
            trackDeviceEnrollmentCalled = true
            trackedDevice = device
        } else {
            throw error ?? EnterpriseDeploymentError.analyticsError("Mock error")
        }
    }
    
    override func generateAnalyticsReport() async throws -> AnalyticsReport {
        if shouldSucceed {
            return AnalyticsReport(
                totalDeployments: 100,
                successRate: 0.95,
                averageDeploymentTime: 30.0,
                timestamp: Date()
            )
        } else {
            throw error ?? EnterpriseDeploymentError.analyticsError("Mock error")
        }
    }
}
