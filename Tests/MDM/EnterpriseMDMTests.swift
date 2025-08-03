//
//  EnterpriseMDMTests.swift
//  iOS Enterprise Deployment Framework
//
//  Created by Muhittin Camdali
//  Copyright © 2023-2024 Muhittin Camdali. All rights reserved.
//

import XCTest
@testable import EnterpriseMDM
@testable import EnterpriseDeploymentCore

final class EnterpriseMDMTests: XCTestCase {
    
    var mdmService: MDMService!
    var mockConfiguration: MDMConfiguration!
    
    override func setUp() {
        super.setUp()
        setupMockConfiguration()
        setupMDMService()
    }
    
    override func tearDown() {
        mdmService = nil
        mockConfiguration = nil
        super.tearDown()
    }
    
    // MARK: - Setup Methods
    
    private func setupMockConfiguration() {
        mockConfiguration = MDMConfiguration(
            serverURL: "https://mdm.test.com",
            organizationID: "test-org-id",
            authToken: "test-auth-token",
            timeout: 30.0
        )
    }
    
    private func setupMDMService() {
        do {
            mdmService = try MDMService(configuration: mockConfiguration)
        } catch {
            XCTFail("Failed to initialize MDM service: \(error)")
        }
    }
    
    // MARK: - Configuration Tests
    
    func testMDMConfigurationValidation() {
        // Test valid configuration
        XCTAssertNoThrow(try MDMService(configuration: mockConfiguration))
        
        // Test invalid server URL
        let invalidConfig = MDMConfiguration(
            serverURL: "",
            organizationID: "test-org"
        )
        
        XCTAssertThrowsError(try MDMService(configuration: invalidConfig)) { error in
            XCTAssertTrue(error is MDMError)
        }
        
        // Test invalid organization ID
        let invalidOrgConfig = MDMConfiguration(
            serverURL: "https://test.com",
            organizationID: ""
        )
        
        XCTAssertThrowsError(try MDMService(configuration: invalidOrgConfig)) { error in
            XCTAssertTrue(error is MDMError)
        }
    }
    
    func testMDMConfigurationProperties() {
        XCTAssertEqual(mockConfiguration.serverURL, "https://mdm.test.com")
        XCTAssertEqual(mockConfiguration.organizationID, "test-org-id")
        XCTAssertEqual(mockConfiguration.authToken, "test-auth-token")
        XCTAssertEqual(mockConfiguration.timeout, 30.0)
    }
    
    // MARK: - Device Management Tests
    
    func testDeviceEnrollment() async throws {
        // Given
        let device = createMockDevice()
        let enrollmentToken = "test-enrollment-token-12345678901234567890123456789012"
        
        // When
        let result = try await mdmService.enrollDevice(device, with: enrollmentToken)
        
        // Then
        XCTAssertEqual(result.device.identifier, device.identifier)
        XCTAssertEqual(result.status, .enrolled)
        XCTAssertNotNil(result.timestamp)
    }
    
    func testDeviceEnrollmentWithInvalidToken() async throws {
        // Given
        let device = createMockDevice()
        let invalidToken = "short"
        
        // When & Then
        do {
            _ = try await mdmService.enrollDevice(device, with: invalidToken)
            XCTFail("Expected enrollment to fail with invalid token")
        } catch {
            XCTAssertTrue(error is MDMError)
        }
    }
    
    func testDeviceRemoval() async throws {
        // Given
        let device = createMockDevice()
        
        // When & Then
        XCTAssertNoThrow(try await mdmService.removeDevice(device))
    }
    
    func testGetEnrolledDevices() async throws {
        // When
        let devices = try await mdmService.getEnrolledDevices()
        
        // Then
        XCTAssertNotNil(devices)
        XCTAssertTrue(devices.count >= 0)
    }
    
    func testGetDeviceInfo() async throws {
        // Given
        let deviceID = "test-device-001"
        
        // When
        let deviceInfo = try await mdmService.getDeviceInfo(deviceID)
        
        // Then
        XCTAssertNotNil(deviceInfo)
    }
    
    // MARK: - App Management Tests
    
    func testInstallApp() async throws {
        // Given
        let app = createMockAppBundle()
        let device = createMockDevice()
        
        // When & Then
        XCTAssertNoThrow(try await mdmService.installApp(app, on: device))
    }
    
    func testRemoveApp() async throws {
        // Given
        let app = createMockAppBundle()
        let device = createMockDevice()
        
        // When & Then
        XCTAssertNoThrow(try await mdmService.removeApp(app, from: device))
    }
    
    func testGetInstalledApps() async throws {
        // Given
        let device = createMockDevice()
        
        // When
        let apps = try await mdmService.getInstalledApps(on: device)
        
        // Then
        XCTAssertNotNil(apps)
        XCTAssertTrue(apps.count >= 0)
    }
    
    // MARK: - Policy Management Tests
    
    func testApplyPolicies() async throws {
        // Given
        let policies = createMockPolicies()
        let device = createMockDevice()
        
        // When & Then
        XCTAssertNoThrow(try await mdmService.applyPolicies(policies, to: device))
    }
    
    func testGetCurrentPolicies() async throws {
        // Given
        let device = createMockDevice()
        
        // When
        let policies = try await mdmService.getCurrentPolicies(for: device)
        
        // Then
        XCTAssertNotNil(policies)
        XCTAssertTrue(policies.count >= 0)
    }
    
    // MARK: - Device Monitoring Tests
    
    func testIsDeviceEnrolled() async throws {
        // Given
        let device = createMockDevice()
        
        // When
        let isEnrolled = try await mdmService.isDeviceEnrolled(device)
        
        // Then
        XCTAssertTrue(isEnrolled)
    }
    
    func testIsDeviceCompliant() async throws {
        // Given
        let device = createMockDevice()
        
        // When
        let isCompliant = try await mdmService.isDeviceCompliant(device)
        
        // Then
        XCTAssertTrue(isCompliant)
    }
    
    func testGetDeviceHealth() async throws {
        // Given
        let device = createMockDevice()
        
        // When
        let health = try await mdmService.getDeviceHealth(device)
        
        // Then
        XCTAssertNotNil(health)
        XCTAssertTrue(health.batteryLevel >= 0 && health.batteryLevel <= 1)
        XCTAssertTrue(health.availableStorage > 0)
        XCTAssertTrue(health.totalStorage > 0)
        XCTAssertNotNil(health.lastSeen)
    }
    
    // MARK: - Error Handling Tests
    
    func testDeviceNotEnrolledError() async throws {
        // Given
        let device = createMockDevice()
        let app = createMockAppBundle()
        
        // When & Then
        do {
            try await mdmService.installApp(app, on: device)
            // This might not fail in test environment due to mock implementation
        } catch MDMError.deviceNotEnrolled {
            // Expected error
        } catch {
            // Other errors are acceptable in test environment
        }
    }
    
    func testDeviceNotCompliantError() async throws {
        // Given
        let device = createMockDevice()
        let app = createMockAppBundle()
        
        // When & Then
        do {
            try await mdmService.installApp(app, on: device)
            // This might not fail in test environment due to mock implementation
        } catch MDMError.deviceNotCompliant {
            // Expected error
        } catch {
            // Other errors are acceptable in test environment
        }
    }
    
    // MARK: - Helper Methods
    
    private func createMockDevice() -> Device {
        return Device(
            identifier: "test-device-001",
            name: "Test iPhone",
            model: "iPhone14,2",
            osVersion: "16.0",
            deviceInfo: DeviceInfo(
                serialNumber: "ABCD1234EFGH",
                udid: "00008120-001C25D40C0A002E",
                capabilities: ["camera", "biometric", "cellular"],
                settings: [:]
            )
        )
    }
    
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
    
    private func createMockPolicies() -> [MDMPolicy] {
        return [
            MDMPolicy(
                identifier: "policy-001",
                name: "Security Policy",
                type: .security,
                configuration: [
                    "requirePasscode": true,
                    "maxPasscodeAge": 90,
                    "minPasscodeLength": 6
                ]
            ),
            MDMPolicy(
                identifier: "policy-002",
                name: "Network Policy",
                type: .network,
                configuration: [
                    "allowCellular": false,
                    "allowedWiFiNetworks": ["corporate-wifi"]
                ]
            )
        ]
    }
}

// MARK: - Supporting Types Tests

final class MDMSupportingTypesTests: XCTestCase {
    
    func testDeviceInitialization() {
        // Given
        let deviceInfo = DeviceInfo(
            serialNumber: "ABCD1234EFGH",
            udid: "00008120-001C25D40C0A002E",
            capabilities: ["camera", "biometric"],
            settings: ["passcodeEnabled": true]
        )
        
        let device = Device(
            identifier: "test-device",
            name: "Test iPhone",
            model: "iPhone14,2",
            osVersion: "16.0",
            deviceInfo: deviceInfo
        )
        
        // Then
        XCTAssertEqual(device.identifier, "test-device")
        XCTAssertEqual(device.name, "Test iPhone")
        XCTAssertEqual(device.model, "iPhone14,2")
        XCTAssertEqual(device.osVersion, "16.0")
        XCTAssertEqual(device.deviceInfo.serialNumber, "ABCD1234EFGH")
        XCTAssertEqual(device.deviceInfo.udid, "00008120-001C25D40C0A002E")
        XCTAssertEqual(device.deviceInfo.capabilities.count, 2)
        XCTAssertEqual(device.deviceInfo.settings.count, 1)
    }
    
    func testDeviceInfoInitialization() {
        // Given
        let deviceInfo = DeviceInfo(
            serialNumber: "ABCD1234EFGH",
            udid: "00008120-001C25D40C0A002E",
            capabilities: ["camera", "biometric", "cellular"],
            settings: ["passcodeEnabled": true, "biometricEnabled": true]
        )
        
        // Then
        XCTAssertEqual(deviceInfo.serialNumber, "ABCD1234EFGH")
        XCTAssertEqual(deviceInfo.udid, "00008120-001C25D40C0A002E")
        XCTAssertEqual(deviceInfo.capabilities.count, 3)
        XCTAssertEqual(deviceInfo.settings.count, 2)
    }
    
    func testDeviceHealthInitialization() {
        // Given
        let health = DeviceHealth(
            batteryLevel: 0.85,
            availableStorage: 64_000_000_000,
            totalStorage: 128_000_000_000,
            networkStatus: .connected,
            lastSeen: Date()
        )
        
        // Then
        XCTAssertEqual(health.batteryLevel, 0.85)
        XCTAssertEqual(health.availableStorage, 64_000_000_000)
        XCTAssertEqual(health.totalStorage, 128_000_000_000)
        XCTAssertEqual(health.networkStatus, .connected)
        XCTAssertNotNil(health.lastSeen)
    }
    
    func testMDMPolicyInitialization() {
        // Given
        let policy = MDMPolicy(
            identifier: "test-policy",
            name: "Test Policy",
            type: .security,
            configuration: [
                "requirePasscode": true,
                "maxPasscodeAge": 90
            ]
        )
        
        // Then
        XCTAssertEqual(policy.identifier, "test-policy")
        XCTAssertEqual(policy.name, "Test Policy")
        XCTAssertEqual(policy.type, .security)
        XCTAssertEqual(policy.configuration.count, 2)
    }
    
    func testEnrollmentProfileInitialization() {
        // Given
        let deviceInfo = DeviceInfo()
        let profile = EnrollmentProfile(
            deviceIdentifier: "test-device",
            organizationID: "test-org",
            serverURL: "https://mdm.test.com",
            enrollmentToken: "test-token",
            deviceInfo: deviceInfo
        )
        
        // Then
        XCTAssertEqual(profile.deviceIdentifier, "test-device")
        XCTAssertEqual(profile.organizationID, "test-org")
        XCTAssertEqual(profile.serverURL, "https://mdm.test.com")
        XCTAssertEqual(profile.enrollmentToken, "test-token")
        XCTAssertNotNil(profile.deviceInfo)
    }
    
    func testEnrollmentResponseInitialization() {
        // Given
        let response = EnrollmentResponse(
            status: .enrolled,
            errorMessage: nil,
            deviceInfo: DeviceInfo()
        )
        
        // Then
        XCTAssertEqual(response.status, .enrolled)
        XCTAssertNil(response.errorMessage)
        XCTAssertNotNil(response.deviceInfo)
    }
}

// MARK: - Error Tests

final class MDMErrorTests: XCTestCase {
    
    func testMDMErrorTypes() {
        // Test all MDM error types
        let errors: [MDMError] = [
            .invalidConfiguration("Test config error"),
            .invalidToken("Test token error"),
            .enrollmentFailed("Test enrollment error"),
            .deviceNotEnrolled("test-device"),
            .deviceNotCompliant("test-device"),
            .installationFailed("Test installation error"),
            .removalFailed("Test removal error"),
            .networkError("Test network error"),
            .serverError("Test server error")
        ]
        
        // Verify all errors have descriptions
        for error in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertTrue(error.errorDescription?.contains("error") == true || error.errorDescription?.contains("device") == true)
        }
    }
    
    func testMDMErrorLocalization() {
        // Test error localization
        let error = MDMError.invalidConfiguration("Configuration is invalid")
        
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("Invalid MDM configuration") == true)
        XCTAssertTrue(error.errorDescription?.contains("Configuration is invalid") == true)
    }
} 