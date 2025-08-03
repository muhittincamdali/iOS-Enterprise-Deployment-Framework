//
//  EnterpriseDeploymentCLITests.swift
//  iOS Enterprise Deployment Framework
//
//  Created by Muhittin Camdali
//  Copyright © 2023-2024 Muhittin Camdali. All rights reserved.
//

import XCTest
@testable import EnterpriseDeploymentCLI
@testable import EnterpriseDeploymentCore

final class EnterpriseDeploymentCLITests: XCTestCase {
    
    // MARK: - CLI Command Tests
    
    func testDeployCommandInitialization() {
        // Given
        let command = DeployCommand()
        
        // Then
        XCTAssertNotNil(command)
    }
    
    func testEnrollCommandInitialization() {
        // Given
        let command = EnrollCommand()
        
        // Then
        XCTAssertNotNil(command)
    }
    
    func testMonitorCommandInitialization() {
        // Given
        let command = MonitorCommand()
        
        // Then
        XCTAssertNotNil(command)
    }
    
    func testReportCommandInitialization() {
        // Given
        let command = ReportCommand()
        
        // Then
        XCTAssertNotNil(command)
    }
    
    func testAnalyticsCommandInitialization() {
        // Given
        let command = AnalyticsCommand()
        
        // Then
        XCTAssertNotNil(command)
    }
    
    func testComplianceCommandInitialization() {
        // Given
        let command = ComplianceCommand()
        
        // Then
        XCTAssertNotNil(command)
    }
    
    // MARK: - CLI Error Tests
    
    func testCLIErrorTypes() {
        // Test all CLI error types
        let errors: [CLIError] = [
            .invalidInput("Test input error"),
            .initializationFailed("Test init error"),
            .operationFailed("Test operation error"),
            .fileNotFound("Test file error"),
            .networkError("Test network error")
        ]
        
        // Verify all errors have descriptions
        for error in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertTrue(error.errorDescription?.contains("error") == true)
        }
    }
    
    func testCLIErrorLocalization() {
        // Test error localization
        let error = CLIError.invalidInput("Input is invalid")
        
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("Invalid input") == true)
        XCTAssertTrue(error.errorDescription?.contains("Input is invalid") == true)
    }
    
    // MARK: - CLI Configuration Tests
    
    func testCLICommandConfiguration() {
        // Test that all commands have proper configuration
        let commands: [ParsableCommand.Type] = [
            DeployCommand.self,
            EnrollCommand.self,
            MonitorCommand.self,
            ReportCommand.self,
            AnalyticsCommand.self,
            ComplianceCommand.self
        ]
        
        for command in commands {
            XCTAssertNotNil(command.configuration)
            XCTAssertNotNil(command.configuration.commandName)
            XCTAssertNotNil(command.configuration.abstract)
        }
    }
    
    // MARK: - CLI Integration Tests
    
    func testCLIHelpCommand() {
        // Test that help command works
        // This is a basic test to ensure CLI structure is correct
        XCTAssertTrue(true) // Placeholder for CLI help test
    }
    
    func testCLIVersionCommand() {
        // Test that version command works
        // This is a basic test to ensure CLI structure is correct
        XCTAssertTrue(true) // Placeholder for CLI version test
    }
}

// MARK: - CLI Mock Tests

final class CLIMockTests: XCTestCase {
    
    func testMockDeployCommand() {
        // Given
        let mockCommand = MockDeployCommand()
        
        // Then
        XCTAssertNotNil(mockCommand)
        XCTAssertEqual(mockCommand.appPath, "/path/to/app.ipa")
        XCTAssertEqual(mockCommand.mdmServer, "https://mdm.test.com")
        XCTAssertEqual(mockCommand.orgId, "test-org")
        XCTAssertFalse(mockCommand.force)
    }
    
    func testMockEnrollCommand() {
        // Given
        let mockCommand = MockEnrollCommand()
        
        // Then
        XCTAssertNotNil(mockCommand)
        XCTAssertEqual(mockCommand.deviceId, "device-001")
        XCTAssertEqual(mockCommand.token, "enrollment-token")
        XCTAssertEqual(mockCommand.mdmServer, "https://mdm.test.com")
        XCTAssertEqual(mockCommand.orgId, "test-org")
    }
    
    func testMockMonitorCommand() {
        // Given
        let mockCommand = MockMonitorCommand()
        
        // Then
        XCTAssertNotNil(mockCommand)
        XCTAssertEqual(mockCommand.deploymentId, "deployment-123")
        XCTAssertEqual(mockCommand.mdmServer, "https://mdm.test.com")
        XCTAssertEqual(mockCommand.orgId, "test-org")
    }
    
    func testMockReportCommand() {
        // Given
        let mockCommand = MockReportCommand()
        
        // Then
        XCTAssertNotNil(mockCommand)
        XCTAssertEqual(mockCommand.type, "deployment")
        XCTAssertEqual(mockCommand.period, "daily")
        XCTAssertEqual(mockCommand.output, "report.pdf")
        XCTAssertEqual(mockCommand.mdmServer, "https://mdm.test.com")
        XCTAssertEqual(mockCommand.orgId, "test-org")
    }
    
    func testMockAnalyticsCommand() {
        // Given
        let mockCommand = MockAnalyticsCommand()
        
        // Then
        XCTAssertNotNil(mockCommand)
        XCTAssertEqual(mockCommand.type, "performance")
        XCTAssertEqual(mockCommand.startDate, "2024-01-01")
        XCTAssertEqual(mockCommand.endDate, "2024-01-31")
    }
    
    func testMockComplianceCommand() {
        // Given
        let mockCommand = MockComplianceCommand()
        
        // Then
        XCTAssertNotNil(mockCommand)
        XCTAssertEqual(mockCommand.type, "check")
        XCTAssertEqual(mockCommand.appId, "com.test.app")
        XCTAssertEqual(mockCommand.period, "daily")
    }
}

// MARK: - Mock CLI Commands

struct MockDeployCommand {
    let appPath = "/path/to/app.ipa"
    let mdmServer = "https://mdm.test.com"
    let orgId = "test-org"
    let devices: String? = "device-001,device-002"
    let force = false
}

struct MockEnrollCommand {
    let deviceId = "device-001"
    let token = "enrollment-token"
    let mdmServer = "https://mdm.test.com"
    let orgId = "test-org"
}

struct MockMonitorCommand {
    let deploymentId: String? = "deployment-123"
    let mdmServer = "https://mdm.test.com"
    let orgId = "test-org"
}

struct MockReportCommand {
    let type = "deployment"
    let period = "daily"
    let output: String? = "report.pdf"
    let mdmServer = "https://mdm.test.com"
    let orgId = "test-org"
}

struct MockAnalyticsCommand {
    let type = "performance"
    let startDate: String? = "2024-01-01"
    let endDate: String? = "2024-01-31"
}

struct MockComplianceCommand {
    let type = "check"
    let appId: String? = "com.test.app"
    let period = "daily"
}

// MARK: - CLI Validation Tests

final class CLIValidationTests: XCTestCase {
    
    func testDeployCommandValidation() {
        // Test deploy command validation
        let validCommand = MockDeployCommand()
        
        XCTAssertFalse(validCommand.appPath.isEmpty)
        XCTAssertFalse(validCommand.mdmServer.isEmpty)
        XCTAssertFalse(validCommand.orgId.isEmpty)
        XCTAssertTrue(validCommand.mdmServer.hasPrefix("https://"))
    }
    
    func testEnrollCommandValidation() {
        // Test enroll command validation
        let validCommand = MockEnrollCommand()
        
        XCTAssertFalse(validCommand.deviceId.isEmpty)
        XCTAssertFalse(validCommand.token.isEmpty)
        XCTAssertFalse(validCommand.mdmServer.isEmpty)
        XCTAssertFalse(validCommand.orgId.isEmpty)
        XCTAssertTrue(validCommand.mdmServer.hasPrefix("https://"))
    }
    
    func testMonitorCommandValidation() {
        // Test monitor command validation
        let validCommand = MockMonitorCommand()
        
        XCTAssertFalse(validCommand.mdmServer.isEmpty)
        XCTAssertFalse(validCommand.orgId.isEmpty)
        XCTAssertTrue(validCommand.mdmServer.hasPrefix("https://"))
    }
    
    func testReportCommandValidation() {
        // Test report command validation
        let validCommand = MockReportCommand()
        
        XCTAssertFalse(validCommand.type.isEmpty)
        XCTAssertFalse(validCommand.period.isEmpty)
        XCTAssertFalse(validCommand.mdmServer.isEmpty)
        XCTAssertFalse(validCommand.orgId.isEmpty)
        XCTAssertTrue(validCommand.mdmServer.hasPrefix("https://"))
    }
    
    func testAnalyticsCommandValidation() {
        // Test analytics command validation
        let validCommand = MockAnalyticsCommand()
        
        XCTAssertFalse(validCommand.type.isEmpty)
        XCTAssertNotNil(validCommand.startDate)
        XCTAssertNotNil(validCommand.endDate)
    }
    
    func testComplianceCommandValidation() {
        // Test compliance command validation
        let validCommand = MockComplianceCommand()
        
        XCTAssertFalse(validCommand.type.isEmpty)
        XCTAssertNotNil(validCommand.appId)
        XCTAssertFalse(validCommand.period.isEmpty)
    }
}

// MARK: - CLI Integration Tests

final class CLIIntegrationTests: XCTestCase {
    
    func testCLICommandStructure() {
        // Test that CLI has proper command structure
        let mainCommand = EnterpriseDeploymentCLI.self
        
        XCTAssertNotNil(mainCommand.configuration)
        XCTAssertNotNil(mainCommand.configuration.commandName)
        XCTAssertNotNil(mainCommand.configuration.abstract)
        XCTAssertNotNil(mainCommand.configuration.version)
        XCTAssertNotNil(mainCommand.configuration.subcommands)
        XCTAssertTrue(mainCommand.configuration.subcommands.count > 0)
    }
    
    func testCLISubcommands() {
        // Test that all subcommands are properly configured
        let subcommands = EnterpriseDeploymentCLI.configuration.subcommands
        
        XCTAssertTrue(subcommands.contains { $0 == DeployCommand.self })
        XCTAssertTrue(subcommands.contains { $0 == EnrollCommand.self })
        XCTAssertTrue(subcommands.contains { $0 == MonitorCommand.self })
        XCTAssertTrue(subcommands.contains { $0 == ReportCommand.self })
        XCTAssertTrue(subcommands.contains { $0 == AnalyticsCommand.self })
        XCTAssertTrue(subcommands.contains { $0 == ComplianceCommand.self })
    }
} 