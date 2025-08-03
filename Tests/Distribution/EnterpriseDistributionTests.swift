//
//  EnterpriseDistributionTests.swift
//  iOS Enterprise Deployment Framework
//
//  Created by Muhittin Camdali
//  Copyright © 2023-2024 Muhittin Camdali. All rights reserved.
//

import XCTest
@testable import EnterpriseDistribution
@testable import EnterpriseDeploymentCore

final class EnterpriseDistributionTests: XCTestCase {
    
    var distributionService: AppDistributionService!
    var mockConfiguration: DistributionConfiguration!
    
    override func setUp() {
        super.setUp()
        setupMockConfiguration()
        setupDistributionService()
    }
    
    override func tearDown() {
        distributionService = nil
        mockConfiguration = nil
        super.tearDown()
    }
    
    // MARK: - Setup Methods
    
    private func setupMockConfiguration() {
        mockConfiguration = DistributionConfiguration(
            appStoreURL: "https://enterprise.test.com/apps",
            requiresSigning: true,
            signingCertificatePath: "/path/to/certificate.p12",
            provisioningProfilePath: "/path/to/profile.mobileprovision",
            uploadTimeout: 300.0
        )
    }
    
    private func setupDistributionService() {
        do {
            distributionService = try AppDistributionService(configuration: mockConfiguration)
        } catch {
            XCTFail("Failed to initialize distribution service: \(error)")
        }
    }
    
    // MARK: - Configuration Tests
    
    func testDistributionConfigurationValidation() {
        // Test valid configuration
        XCTAssertNoThrow(try AppDistributionService(configuration: mockConfiguration))
        
        // Test invalid app store URL
        let invalidConfig = DistributionConfiguration(
            appStoreURL: "",
            requiresSigning: false
        )
        
        XCTAssertThrowsError(try AppDistributionService(configuration: invalidConfig)) { error in
            XCTAssertTrue(error is DistributionError)
        }
        
        // Test invalid URL format
        let invalidURLConfig = DistributionConfiguration(
            appStoreURL: "invalid-url",
            requiresSigning: false
        )
        
        XCTAssertThrowsError(try AppDistributionService(configuration: invalidURLConfig)) { error in
            XCTAssertTrue(error is DistributionError)
        }
    }
    
    func testDistributionConfigurationProperties() {
        XCTAssertEqual(mockConfiguration.appStoreURL, "https://enterprise.test.com/apps")
        XCTAssertTrue(mockConfiguration.requiresSigning)
        XCTAssertEqual(mockConfiguration.signingCertificatePath, "/path/to/certificate.p12")
        XCTAssertEqual(mockConfiguration.provisioningProfilePath, "/path/to/profile.mobileprovision")
        XCTAssertEqual(mockConfiguration.uploadTimeout, 300.0)
    }
    
    // MARK: - App Distribution Tests
    
    func testUploadApp() async throws {
        // Given
        let appBundle = createMockAppBundle()
        
        // When
        let result = try await distributionService.uploadApp(appBundle)
        
        // Then
        XCTAssertEqual(result.appIdentifier, appBundle.identifier)
        XCTAssertNotNil(result.uploadID)
        XCTAssertNotNil(result.appStoreURL)
        XCTAssertNotNil(result.uploadTimestamp)
        XCTAssertTrue(result.fileSize > 0)
    }
    
    func testUploadAppWithInvalidBundle() async throws {
        // Given
        let invalidApp = AppBundle(
            identifier: "",
            version: nil,
            bundleURL: nil
        )
        
        // When & Then
        do {
            _ = try await distributionService.uploadApp(invalidApp)
            XCTFail("Expected upload to fail with invalid app bundle")
        } catch {
            XCTAssertTrue(error is DistributionError)
        }
    }
    
    func testSignApp() async throws {
        // Given
        let appBundle = createMockAppBundle()
        
        // When
        let signedApp = try await distributionService.signApp(appBundle)
        
        // Then
        XCTAssertEqual(signedApp.identifier, appBundle.identifier)
        XCTAssertTrue(signedApp.isSigned)
        XCTAssertNotNil(signedApp.signature)
    }
    
    func testSignAppWithInvalidCertificate() async throws {
        // Given
        let invalidConfig = DistributionConfiguration(
            appStoreURL: "https://test.com",
            requiresSigning: true,
            signingCertificatePath: "",
            provisioningProfilePath: ""
        )
        
        let invalidService = try AppDistributionService(configuration: invalidConfig)
        let appBundle = createMockAppBundle()
        
        // When & Then
        do {
            _ = try await invalidService.signApp(appBundle)
            XCTFail("Expected signing to fail with invalid certificate")
        } catch {
            XCTAssertTrue(error is DistributionError)
        }
    }
    
    func testGetAvailableApps() async throws {
        // When
        let apps = try await distributionService.getAvailableApps()
        
        // Then
        XCTAssertNotNil(apps)
        XCTAssertTrue(apps.count >= 0)
    }
    
    func testRemoveApp() async throws {
        // Given
        let appBundle = createMockAppBundle()
        
        // When & Then
        XCTAssertNoThrow(try await distributionService.removeApp(appBundle))
    }
    
    // MARK: - App Bundle Tests
    
    func testAppBundleInitialization() {
        // Given
        let appBundle = AppBundle(
            identifier: "com.test.app",
            version: "1.0.0",
            bundleURL: URL(string: "https://test.com/app.ipa"),
            metadata: AppMetadata(
                name: "Test App",
                description: "Test application",
                category: "Productivity",
                size: 50_000_000
            ),
            isSigned: true,
            signature: "test-signature"
        )
        
        // Then
        XCTAssertEqual(appBundle.identifier, "com.test.app")
        XCTAssertEqual(appBundle.version, "1.0.0")
        XCTAssertNotNil(appBundle.bundleURL)
        XCTAssertNotNil(appBundle.metadata)
        XCTAssertTrue(appBundle.isSigned)
        XCTAssertEqual(appBundle.signature, "test-signature")
    }
    
    func testAppMetadataInitialization() {
        // Given
        let metadata = AppMetadata(
            name: "Test App",
            description: "Test application description",
            category: "Productivity",
            size: 75_000_000,
            iconURL: URL(string: "https://test.com/icon.png"),
            screenshots: [
                URL(string: "https://test.com/screenshot1.png")!,
                URL(string: "https://test.com/screenshot2.png")!
            ]
        )
        
        // Then
        XCTAssertEqual(metadata.name, "Test App")
        XCTAssertEqual(metadata.description, "Test application description")
        XCTAssertEqual(metadata.category, "Productivity")
        XCTAssertEqual(metadata.size, 75_000_000)
        XCTAssertNotNil(metadata.iconURL)
        XCTAssertEqual(metadata.screenshots.count, 2)
    }
    
    func testUploadResultInitialization() {
        // Given
        let result = UploadResult(
            appIdentifier: "com.test.app",
            uploadID: "upload-123",
            appStoreURL: "https://enterprise.test.com/apps/com.test.app",
            uploadTimestamp: Date(),
            fileSize: 50_000_000
        )
        
        // Then
        XCTAssertEqual(result.appIdentifier, "com.test.app")
        XCTAssertEqual(result.uploadID, "upload-123")
        XCTAssertEqual(result.appStoreURL, "https://enterprise.test.com/apps/com.test.app")
        XCTAssertNotNil(result.uploadTimestamp)
        XCTAssertEqual(result.fileSize, 50_000_000)
    }
    
    // MARK: - Error Handling Tests
    
    func testDistributionErrorTypes() {
        // Test all distribution error types
        let errors: [DistributionError] = [
            .invalidConfiguration("Test config error"),
            .invalidAppBundle("Test app bundle error"),
            .invalidSigningCertificate("Test certificate error"),
            .signingFailed("Test signing error"),
            .signatureVerificationFailed("Test verification error"),
            .uploadFailed("Test upload error"),
            .removalFailed("Test removal error"),
            .networkError("Test network error"),
            .serverError("Test server error")
        ]
        
        // Verify all errors have descriptions
        for error in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertTrue(error.errorDescription?.contains("error") == true)
        }
    }
    
    func testDistributionErrorLocalization() {
        // Test error localization
        let error = DistributionError.invalidConfiguration("Configuration is invalid")
        
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("Invalid distribution configuration") == true)
        XCTAssertTrue(error.errorDescription?.contains("Configuration is invalid") == true)
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
}

// MARK: - Integration Tests

final class DistributionIntegrationTests: XCTestCase {
    
    func testEndToEndAppDistribution() async throws {
        // Given
        let config = DistributionConfiguration(
            appStoreURL: "https://enterprise.test.com/apps",
            requiresSigning: true,
            signingCertificatePath: "/path/to/certificate.p12",
            provisioningProfilePath: "/path/to/profile.mobileprovision"
        )
        
        let service = try AppDistributionService(configuration: config)
        let appBundle = AppBundle(
            identifier: "com.test.app",
            version: "1.0.0",
            bundleURL: URL(string: "https://test.com/app.ipa")
        )
        
        // When
        let uploadResult = try await service.uploadApp(appBundle)
        
        // Then
        XCTAssertEqual(uploadResult.appIdentifier, appBundle.identifier)
        XCTAssertNotNil(uploadResult.uploadID)
        XCTAssertNotNil(uploadResult.appStoreURL)
    }
    
    func testAppSigningAndUpload() async throws {
        // Given
        let config = DistributionConfiguration(
            appStoreURL: "https://enterprise.test.com/apps",
            requiresSigning: true,
            signingCertificatePath: "/path/to/certificate.p12",
            provisioningProfilePath: "/path/to/profile.mobileprovision"
        )
        
        let service = try AppDistributionService(configuration: config)
        let appBundle = AppBundle(
            identifier: "com.test.app",
            version: "1.0.0",
            bundleURL: URL(string: "https://test.com/app.ipa")
        )
        
        // When
        let signedApp = try await service.signApp(appBundle)
        let uploadResult = try await service.uploadApp(signedApp)
        
        // Then
        XCTAssertTrue(signedApp.isSigned)
        XCTAssertNotNil(signedApp.signature)
        XCTAssertEqual(uploadResult.appIdentifier, signedApp.identifier)
    }
} 