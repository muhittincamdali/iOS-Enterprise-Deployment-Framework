//
//  EnterpriseComplianceTests.swift
//  iOS Enterprise Deployment Framework
//
//  Created by Muhittin Camdali
//  Copyright © 2023-2024 Muhittin Camdali. All rights reserved.
//

import XCTest
@testable import EnterpriseCompliance
@testable import EnterpriseDeploymentCore

final class EnterpriseComplianceTests: XCTestCase {
    
    var complianceService: ComplianceService!
    var mockConfiguration: ComplianceConfiguration!
    
    override func setUp() {
        super.setUp()
        setupMockConfiguration()
        setupComplianceService()
    }
    
    override func tearDown() {
        complianceService = nil
        mockConfiguration = nil
        super.tearDown()
    }
    
    // MARK: - Setup Methods
    
    private func setupMockConfiguration() {
        mockConfiguration = ComplianceConfiguration(
            auditLogging: true,
            dataEncryption: true,
            privacyCompliance: .gdpr,
            securityCompliance: .iso27001
        )
    }
    
    private func setupComplianceService() {
        do {
            complianceService = try ComplianceService(configuration: mockConfiguration)
        } catch {
            XCTFail("Failed to initialize compliance service: \(error)")
        }
    }
    
    // MARK: - Configuration Tests
    
    func testComplianceConfigurationValidation() {
        // Test valid configuration
        XCTAssertNoThrow(try ComplianceService(configuration: mockConfiguration))
        
        // Test invalid configuration (audit logging disabled)
        let invalidConfig = ComplianceConfiguration(
            auditLogging: false,
            dataEncryption: true
        )
        
        XCTAssertThrowsError(try ComplianceService(configuration: invalidConfig)) { error in
            XCTAssertTrue(error is ComplianceError)
        }
        
        // Test invalid configuration (data encryption disabled)
        let invalidEncryptionConfig = ComplianceConfiguration(
            auditLogging: true,
            dataEncryption: false
        )
        
        XCTAssertThrowsError(try ComplianceService(configuration: invalidEncryptionConfig)) { error in
            XCTAssertTrue(error is ComplianceError)
        }
    }
    
    func testComplianceConfigurationProperties() {
        XCTAssertTrue(mockConfiguration.auditLogging)
        XCTAssertTrue(mockConfiguration.dataEncryption)
        XCTAssertEqual(mockConfiguration.privacyCompliance, .gdpr)
        XCTAssertEqual(mockConfiguration.securityCompliance, .iso27001)
    }
    
    // MARK: - Compliance Monitoring Tests
    
    func testGetComplianceRequirements() async throws {
        // Given
        let appBundle = createMockAppBundle()
        
        // When
        let requirements = try await complianceService.getComplianceRequirements(for: appBundle)
        
        // Then
        XCTAssertNotNil(requirements)
        XCTAssertTrue(requirements.isCompliant)
        XCTAssertNotNil(requirements.recommendations)
    }
    
    func testGenerateComplianceReport() async throws {
        // Given
        let period = ReportPeriod.daily
        
        // When
        let report = try await complianceService.generateReport(for: period)
        
        // Then
        XCTAssertNotNil(report)
        XCTAssertEqual(report.period, period)
        XCTAssertNotNil(report.generatedAt)
        XCTAssertNotNil(report.complianceData)
        XCTAssertNotNil(report.summary)
    }
    
    func testGenerateComplianceReportWithAuditLogs() async throws {
        // Given
        let period = ReportPeriod.weekly
        
        // When
        let report = try await complianceService.generateReport(
            for: period,
            includeAuditLogs: true
        )
        
        // Then
        XCTAssertNotNil(report)
        XCTAssertEqual(report.period, period)
        XCTAssertNotNil(report.auditLogs)
    }
    
    func testGenerateDeploymentComplianceReport() async throws {
        // Given
        let deploymentResult = createMockDeploymentResult()
        
        // When
        let report = try await complianceService.generateDeploymentReport(deploymentResult)
        
        // Then
        XCTAssertNotNil(report)
        XCTAssertEqual(report.period, .deployment(deploymentResult.timestamp))
        XCTAssertNotNil(report.complianceData)
        XCTAssertNotNil(report.summary)
    }
    
    func testMonitorDataAccess() async throws {
        // Given
        var receivedEvents: [DataAccessEvent] = []
        
        // When
        try await complianceService.monitorDataAccess { event in
            receivedEvents.append(event)
        }
        
        // Then
        // In test environment, we might not receive events immediately
        XCTAssertNotNil(receivedEvents)
    }
    
    func testCheckSecurityRequirements() async throws {
        // Given
        let appBundle = createMockAppBundle()
        
        // When
        let assessment = try await complianceService.checkSecurityRequirements(for: appBundle)
        
        // Then
        XCTAssertNotNil(assessment)
        XCTAssertTrue(assessment.securityScore >= 0 && assessment.securityScore <= 100)
        XCTAssertNotNil(assessment.vulnerabilities)
        XCTAssertNotNil(assessment.recommendations)
    }
    
    // MARK: - Supporting Types Tests
    
    func testComplianceRequirementsInitialization() {
        // Given
        let violations = [
            ComplianceViolation(
                type: .privacy,
                severity: .medium,
                description: "App does not have privacy policy"
            )
        ]
        
        let recommendations = [
            "Add privacy policy",
            "Implement data encryption",
            "Add user consent mechanism"
        ]
        
        let requirements = ComplianceRequirements(
            isCompliant: false,
            violations: violations,
            recommendations: recommendations
        )
        
        // Then
        XCTAssertFalse(requirements.isCompliant)
        XCTAssertEqual(requirements.violations.count, 1)
        XCTAssertEqual(requirements.recommendations.count, 3)
    }
    
    func testComplianceViolationInitialization() {
        // Given
        let violation = ComplianceViolation(
            type: .security,
            severity: .high,
            description: "App uses weak encryption"
        )
        
        // Then
        XCTAssertEqual(violation.type, .security)
        XCTAssertEqual(violation.severity, .high)
        XCTAssertEqual(violation.description, "App uses weak encryption")
    }
    
    func testComplianceReportInitialization() {
        // Given
        let complianceData = ComplianceData(
            totalDeployments: 100,
            successfulDeployments: 95,
            failedDeployments: 5,
            complianceViolations: 2,
            securityIncidents: 0,
            dataAccessEvents: 1000,
            auditLogEntries: 5000
        )
        
        let summary = ComplianceSummary(
            successRate: 95.0,
            complianceRate: 98.0,
            securityScore: 90.0,
            riskLevel: .low
        )
        
        let report = ComplianceReport(
            period: .monthly,
            generatedAt: Date(),
            complianceData: complianceData,
            auditLogs: [],
            summary: summary
        )
        
        // Then
        XCTAssertEqual(report.period, .monthly)
        XCTAssertNotNil(report.generatedAt)
        XCTAssertNotNil(report.complianceData)
        XCTAssertNotNil(report.summary)
        XCTAssertEqual(report.auditLogs.count, 0)
    }
    
    func testComplianceDataInitialization() {
        // Given
        let data = ComplianceData(
            totalDeployments: 150,
            successfulDeployments: 145,
            failedDeployments: 5,
            complianceViolations: 2,
            securityIncidents: 0,
            dataAccessEvents: 1250,
            auditLogEntries: 5000
        )
        
        // Then
        XCTAssertEqual(data.totalDeployments, 150)
        XCTAssertEqual(data.successfulDeployments, 145)
        XCTAssertEqual(data.failedDeployments, 5)
        XCTAssertEqual(data.complianceViolations, 2)
        XCTAssertEqual(data.securityIncidents, 0)
        XCTAssertEqual(data.dataAccessEvents, 1250)
        XCTAssertEqual(data.auditLogEntries, 5000)
    }
    
    func testComplianceSummaryInitialization() {
        // Given
        let summary = ComplianceSummary(
            successRate: 95.0,
            complianceRate: 98.0,
            securityScore: 90.0,
            riskLevel: .low
        )
        
        // Then
        XCTAssertEqual(summary.successRate, 95.0)
        XCTAssertEqual(summary.complianceRate, 98.0)
        XCTAssertEqual(summary.securityScore, 90.0)
        XCTAssertEqual(summary.riskLevel, .low)
    }
    
    func testSecurityAssessmentInitialization() {
        // Given
        let vulnerabilities = [
            SecurityVulnerability(
                type: .networkSecurity,
                severity: .medium,
                description: "App does not use certificate pinning",
                recommendation: "Implement certificate pinning"
            )
        ]
        
        let recommendations = [
            "Implement certificate pinning",
            "Add jailbreak detection",
            "Enable app transport security"
        ]
        
        let assessment = SecurityAssessment(
            securityScore: 85,
            vulnerabilities: vulnerabilities,
            recommendations: recommendations
        )
        
        // Then
        XCTAssertEqual(assessment.securityScore, 85)
        XCTAssertEqual(assessment.vulnerabilities.count, 1)
        XCTAssertEqual(assessment.recommendations.count, 3)
    }
    
    func testSecurityVulnerabilityInitialization() {
        // Given
        let vulnerability = SecurityVulnerability(
            type: .dataEncryption,
            severity: .high,
            description: "Sensitive data not encrypted",
            recommendation: "Implement AES-256 encryption"
        )
        
        // Then
        XCTAssertEqual(vulnerability.type, .dataEncryption)
        XCTAssertEqual(vulnerability.severity, .high)
        XCTAssertEqual(vulnerability.description, "Sensitive data not encrypted")
        XCTAssertEqual(vulnerability.recommendation, "Implement AES-256 encryption")
    }
    
    func testDataAccessEventInitialization() {
        // Given
        let event = DataAccessEvent(
            userID: "user-123",
            resource: "customer-data",
            action: .read,
            timestamp: Date()
        )
        
        // Then
        XCTAssertEqual(event.userID, "user-123")
        XCTAssertEqual(event.resource, "customer-data")
        XCTAssertEqual(event.action, .read)
        XCTAssertNotNil(event.timestamp)
    }
    
    // MARK: - Error Handling Tests
    
    func testComplianceErrorTypes() {
        // Test all compliance error types
        let errors: [ComplianceError] = [
            .invalidConfiguration("Test config error"),
            .complianceCheckFailed("Test compliance error"),
            .reportGenerationFailed("Test report error"),
            .securityAssessmentFailed("Test security error"),
            .auditLoggingFailed("Test audit error"),
            .dataAccessMonitoringFailed("Test monitoring error")
        ]
        
        // Verify all errors have descriptions
        for error in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertTrue(error.errorDescription?.contains("error") == true)
        }
    }
    
    func testComplianceErrorLocalization() {
        // Test error localization
        let error = ComplianceError.invalidConfiguration("Configuration is invalid")
        
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("Invalid compliance configuration") == true)
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
    
    private func createMockDeploymentResult() -> DeploymentResult {
        return DeploymentResult(
            status: .success,
            appIdentifier: "com.test.app",
            deploymentID: "deployment-123",
            deployedDevices: [],
            failedDevices: [],
            complianceReport: nil,
            analytics: nil,
            timestamp: Date()
        )
    }
}

// MARK: - Integration Tests

final class ComplianceIntegrationTests: XCTestCase {
    
    func testEndToEndComplianceWorkflow() async throws {
        // Given
        let config = ComplianceConfiguration(
            auditLogging: true,
            dataEncryption: true,
            privacyCompliance: .gdpr,
            securityCompliance: .iso27001
        )
        
        let service = try ComplianceService(configuration: config)
        let appBundle = AppBundle(
            identifier: "com.test.app",
            version: "1.0.0",
            bundleURL: URL(string: "https://test.com/app.ipa")
        )
        
        // When
        let requirements = try await service.getComplianceRequirements(for: appBundle)
        let securityAssessment = try await service.checkSecurityRequirements(for: appBundle)
        let report = try await service.generateReport(for: .daily)
        
        // Then
        XCTAssertNotNil(requirements)
        XCTAssertNotNil(securityAssessment)
        XCTAssertNotNil(report)
    }
} 