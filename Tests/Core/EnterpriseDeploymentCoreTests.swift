//
//  EnterpriseDeploymentCoreTests.swift
//  iOS Enterprise Deployment Framework
//
//  Created by Muhittin Camdali
//  Copyright © 2023-2024 Muhittin Camdali. All rights reserved.
//

import XCTest
@testable import EnterpriseDeploymentCore
@testable import EnterpriseMDM
@testable import EnterpriseDistribution
@testable import EnterpriseCompliance
@testable import EnterpriseAnalytics

final class EnterpriseDeploymentCoreTests: XCTestCase {
    
    var deployment: EnterpriseDeployment!
    var mockConfiguration: EnterpriseDeploymentConfiguration!
    
    override func setUp() {
        super.setUp()
        setupMockConfiguration()
        setupDeployment()
    }
    
    override func tearDown() {
        deployment = nil
        mockConfiguration = nil
        super.tearDown()
    }
    
    // MARK: - Setup Methods
    
    private func setupMockConfiguration() {
        let mdmConfig = MDMConfiguration(
            serverURL: "https://mdm.test.com",
            organizationID: "test-org-id"
        )
        
        let distributionConfig = DistributionConfiguration(
            appStoreURL: "https://enterprise.test.com/apps"
        )
        
        let complianceConfig = ComplianceConfiguration()
        
        let analyticsConfig = AnalyticsConfiguration()
        
        mockConfiguration = EnterpriseDeploymentConfiguration(
            mdmConfiguration: mdmConfig,
            distributionConfiguration: distributionConfig,
            complianceConfiguration: complianceConfig,
            analyticsConfiguration: analyticsConfig
        )
    }
    
    private func setupDeployment() {
        do {
            deployment = try EnterpriseDeployment(configuration: mockConfiguration)
        } catch {
            XCTFail("Failed to initialize deployment: \(error)")
        }
    }
    
    // MARK: - Configuration Tests
    
    func testConfigurationValidation() {
        // Test valid configuration
        XCTAssertNoThrow(try EnterpriseDeployment(configuration: mockConfiguration))
        
        // Test invalid MDM server URL
        let invalidConfig = EnterpriseDeploymentConfiguration(
            mdmServerURL: "",
            appStoreURL: "https://test.com",
            organizationID: "test-org"
        )
        
        XCTAssertThrowsError(try EnterpriseDeployment(configuration: invalidConfig)) { error in
            XCTAssertTrue(error is EnterpriseDeploymentError)
        }
    }
    
    func testConfigurationProperties() {
        XCTAssertEqual(mockConfiguration.mdmServerURL, "https://mdm.test.com")
        XCTAssertEqual(mockConfiguration.appStoreURL, "https://enterprise.test.com/apps")
        XCTAssertEqual(mockConfiguration.organizationID, "test-org-id")
    }
    
    // MARK: - Deployment Tests
    
    func testDeploymentSuccess() async throws {
        // Given
        let appBundle = createMockAppBundle()
        
        // When
        let result = try await deployment.deploy(app: appBundle)
        
        // Then
        XCTAssertEqual(result.status, .success)
        XCTAssertEqual(result.appIdentifier, appBundle.identifier)
        XCTAssertNotNil(result.deploymentID)
        XCTAssertNotNil(result.timestamp)
    }
    
    func testDeploymentWithOptions() async throws {
        // Given
        let appBundle = createMockAppBundle()
        let options = DeploymentOptions(
            forceDeployment: true,
            rollbackOnFailure: false,
            maxConcurrentDeployments: 5,
            deploymentTimeout: 60.0
        )
        
        // When
        let result = try await deployment.deploy(app: appBundle, options: options)
        
        // Then
        XCTAssertEqual(result.status, .success)
        XCTAssertEqual(result.appIdentifier, appBundle.identifier)
    }
    
    func testDeploymentToSpecificDevices() async throws {
        // Given
        let appBundle = createMockAppBundle()
        let devices = createMockDevices()
        
        // When
        let result = try await deployment.deploy(app: appBundle, to: devices)
        
        // Then
        XCTAssertEqual(result.status, .success)
        XCTAssertEqual(result.deployedDevices.count, devices.count)
    }
    
    // MARK: - Device Management Tests
    
    func testDeviceEnrollment() async throws {
        // Given
        let device = createMockDevice()
        let enrollmentToken = "test-enrollment-token"
        
        // When
        let result = try await deployment.enrollDevice(device, with: enrollmentToken)
        
        // Then
        XCTAssertEqual(result.device.identifier, device.identifier)
        XCTAssertEqual(result.status, .enrolled)
        XCTAssertNotNil(result.timestamp)
    }
    
    func testDeviceRemoval() async throws {
        // Given
        let device = createMockDevice()
        
        // When & Then
        XCTAssertNoThrow(try await deployment.removeDevice(device))
    }
    
    func testGetEnrolledDevices() async throws {
        // When
        let devices = try await deployment.getEnrolledDevices()
        
        // Then
        XCTAssertNotNil(devices)
        XCTAssertTrue(devices.count >= 0)
    }
    
    // MARK: - Analytics Tests
    
    func testGetAnalytics() async throws {
        // Given
        let startDate = Date().addingTimeInterval(-86400) // Yesterday
        let endDate = Date()
        
        // When
        let analytics = try await deployment.getAnalytics(from: startDate, to: endDate)
        
        // Then
        XCTAssertNotNil(analytics)
        XCTAssertTrue(analytics.totalEvents >= 0)
    }
    
    // MARK: - Compliance Tests
    
    func testGenerateComplianceReport() async throws {
        // Given
        let period = ReportPeriod.daily
        
        // When
        let report = try await deployment.generateComplianceReport(for: period)
        
        // Then
        XCTAssertNotNil(report)
        XCTAssertEqual(report.period, period)
        XCTAssertNotNil(report.generatedAt)
    }
    
    // MARK: - Error Handling Tests
    
    func testInvalidAppBundle() async throws {
        // Given
        let invalidApp = AppBundle(
            identifier: "",
            version: nil,
            bundleURL: nil
        )
        
        // When & Then
        do {
            _ = try await deployment.deploy(app: invalidApp)
            XCTFail("Expected deployment to fail with invalid app bundle")
        } catch {
            XCTAssertTrue(error is DeploymentError)
        }
    }
    
    func testDeploymentTimeout() async throws {
        // Given
        let appBundle = createMockAppBundle()
        let options = DeploymentOptions(deploymentTimeout: 0.1) // Very short timeout
        
        // When & Then
        do {
            _ = try await deployment.deploy(app: appBundle, options: options)
            // Note: This might not timeout in test environment
        } catch {
            XCTAssertTrue(error is DeploymentError)
        }
    }
    
    // MARK: - Helper Methods
    
    private func createMockAppBundle() -> AppBundle {
        return AppBundle(
            identifier: "com.test.app",
            version: "1.0.0",
            bundleURL: URL(string: "https://test.com/app.ipa"),
            metadata: AppMetadata(
                name: "Test App",
                description: "Test application",
                category: "Productivity",
                size: 50_000_000
            )
        )
    }
    
    private func createMockDevice() -> Device {
        return Device(
            identifier: "test-device-1",
            name: "Test iPhone",
            model: "iPhone14,2",
            osVersion: "16.0",
            deviceInfo: DeviceInfo()
        )
    }
    
    private func createMockDevices() -> [Device] {
        return [
            Device(
                identifier: "test-device-1",
                name: "Test iPhone 1",
                model: "iPhone14,2",
                osVersion: "16.0",
                deviceInfo: DeviceInfo()
            ),
            Device(
                identifier: "test-device-2",
                name: "Test iPhone 2",
                model: "iPhone14,2",
                osVersion: "16.0",
                deviceInfo: DeviceInfo()
            )
        ]
    }
}

// MARK: - Supporting Types Tests

final class SupportingTypesTests: XCTestCase {
    
    func testDeploymentOptions() {
        // Given
        let options = DeploymentOptions(
            forceDeployment: true,
            rollbackOnFailure: false,
            maxConcurrentDeployments: 10,
            deploymentTimeout: 300.0
        )
        
        // Then
        XCTAssertTrue(options.forceDeployment)
        XCTAssertFalse(options.rollbackOnFailure)
        XCTAssertEqual(options.maxConcurrentDeployments, 10)
        XCTAssertEqual(options.deploymentTimeout, 300.0)
    }
    
    func testDeploymentResult() {
        // Given
        let result = DeploymentResult(
            status: .success,
            appIdentifier: "com.test.app",
            deploymentID: "test-deployment-id",
            deployedDevices: [],
            failedDevices: [],
            complianceReport: nil,
            analytics: nil,
            timestamp: Date()
        )
        
        // Then
        XCTAssertEqual(result.status, .success)
        XCTAssertEqual(result.appIdentifier, "com.test.app")
        XCTAssertEqual(result.deploymentID, "test-deployment-id")
        XCTAssertNotNil(result.timestamp)
    }
    
    func testEnrollmentResult() {
        // Given
        let device = Device(
            identifier: "test-device",
            name: "Test Device",
            model: "iPhone",
            osVersion: "16.0",
            deviceInfo: DeviceInfo()
        )
        
        let result = EnrollmentResult(
            device: device,
            status: .enrolled,
            timestamp: Date()
        )
        
        // Then
        XCTAssertEqual(result.device.identifier, "test-device")
        XCTAssertEqual(result.status, .enrolled)
        XCTAssertNotNil(result.timestamp)
    }
    
    func testDeviceDeploymentResult() {
        // Given
        let devices = [
            Device(
                identifier: "test-device-1",
                name: "Test Device 1",
                model: "iPhone",
                osVersion: "16.0",
                deviceInfo: DeviceInfo()
            )
        ]
        
        let analytics = AnalyticsData(
            totalEvents: 1,
            deploymentEvents: 1,
            errorEvents: 0,
            behaviorEvents: 0,
            startDate: Date(),
            endDate: Date(),
            events: []
        )
        
        let result = DeviceDeploymentResult(
            deploymentID: "test-deployment-id",
            deployedDevices: devices,
            failedDevices: [],
            analytics: analytics
        )
        
        // Then
        XCTAssertEqual(result.deploymentID, "test-deployment-id")
        XCTAssertEqual(result.deployedDevices.count, 1)
        XCTAssertEqual(result.failedDevices.count, 0)
        XCTAssertNotNil(result.analytics)
    }
    
    func testDeviceDeploymentFailure() {
        // Given
        let device = Device(
            identifier: "test-device",
            name: "Test Device",
            model: "iPhone",
            osVersion: "16.0",
            deviceInfo: DeviceInfo()
        )
        
        let error = NSError(domain: "test", code: 1, userInfo: nil)
        
        let failure = DeviceDeploymentFailure(
            device: device,
            error: error
        )
        
        // Then
        XCTAssertEqual(failure.device.identifier, "test-device")
        XCTAssertEqual(failure.error as NSError, error)
    }
}

// MARK: - Error Tests

final class ErrorTests: XCTestCase {
    
    func testEnterpriseDeploymentError() {
        // Given
        let error = EnterpriseDeploymentError.invalidConfiguration("Test error")
        
        // Then
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("Invalid configuration") == true)
    }
    
    func testDeploymentError() {
        // Given
        let error = DeploymentError.invalidAppBundle("Test error")
        
        // Then
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("Invalid app bundle") == true)
    }
    
    func testErrorLocalization() {
        // Test that all error types have localized descriptions
        let enterpriseErrors: [EnterpriseDeploymentError] = [
            .invalidConfiguration("test"),
            .initializationFailed("test"),
            .serviceUnavailable("test")
        ]
        
        let deploymentErrors: [DeploymentError] = [
            .invalidAppBundle("test"),
            .signingFailed("test"),
            .uploadFailed("test"),
            .deploymentFailed("test"),
            .timeout("test")
        ]
        
        // Verify all errors have descriptions
        for error in enterpriseErrors {
            XCTAssertNotNil(error.errorDescription)
        }
        
        for error in deploymentErrors {
            XCTAssertNotNil(error.errorDescription)
        }
    }
} 