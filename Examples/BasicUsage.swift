//
//  BasicUsage.swift
//  iOS Enterprise Deployment Framework
//
//  Created by Muhittin Camdali
//  Copyright © 2023-2024 Muhittin Camdali. All rights reserved.
//

import Foundation
import EnterpriseDeploymentCore
import EnterpriseMDM
import EnterpriseDistribution
import EnterpriseCompliance
import EnterpriseAnalytics

/// Basic usage examples for the iOS Enterprise Deployment Framework.
///
/// This file demonstrates common use cases and patterns for enterprise
/// deployment, MDM integration, and compliance monitoring.
public class BasicUsageExamples {
    
    // MARK: - Framework Initialization
    
    /// Example: Initialize the enterprise deployment framework.
    public static func initializeFramework() throws -> EnterpriseDeployment {
        // Create MDM configuration
        let mdmConfig = MDMConfiguration(
            serverURL: "https://mdm.company.com",
            organizationID: "company-org-id",
            authToken: "your-auth-token"
        )
        
        // Create distribution configuration
        let distributionConfig = DistributionConfiguration(
            appStoreURL: "https://enterprise.company.com/apps",
            requiresSigning: true,
            signingCertificatePath: "/path/to/certificate.p12",
            provisioningProfilePath: "/path/to/profile.mobileprovision"
        )
        
        // Create compliance configuration
        let complianceConfig = ComplianceConfiguration(
            auditLogging: true,
            dataEncryption: true,
            privacyCompliance: .gdpr,
            securityCompliance: .iso27001
        )
        
        // Create analytics configuration
        let analyticsConfig = AnalyticsConfiguration(
            trackingEnabled: true,
            crashReporting: true,
            performanceMonitoring: true,
            behaviorTracking: true
        )
        
        // Create enterprise deployment configuration
        let config = EnterpriseDeploymentConfiguration(
            mdmConfiguration: mdmConfig,
            distributionConfiguration: distributionConfig,
            complianceConfiguration: complianceConfig,
            analyticsConfiguration: analyticsConfig
        )
        
        // Initialize framework
        return try EnterpriseDeployment(configuration: config)
    }
    
    // MARK: - App Deployment
    
    /// Example: Deploy an app to enterprise devices.
    public static func deployApp() async throws {
        // Initialize framework
        let framework = try initializeFramework()
        
        // Create app bundle
        let appBundle = AppBundle(
            identifier: "com.company.enterprise-app",
            version: "1.0.0",
            bundleURL: URL(string: "https://enterprise.company.com/apps/enterprise-app.ipa"),
            metadata: AppMetadata(
                name: "Enterprise App",
                description: "Internal enterprise application",
                category: "Productivity",
                size: 75_000_000
            )
        )
        
        // Deploy app
        let result = try await framework.deploy(app: appBundle)
        
        print("✅ App deployed successfully!")
        print("📱 Deployed to \(result.deployedDevices.count) devices")
        print("❌ Failed on \(result.failedDevices.count) devices")
        print("🆔 Deployment ID: \(result.deploymentID)")
    }
    
    /// Example: Deploy app with custom options.
    public static func deployAppWithOptions() async throws {
        // Initialize framework
        let framework = try initializeFramework()
        
        // Create app bundle
        let appBundle = AppBundle(
            identifier: "com.company.enterprise-app",
            version: "1.0.0",
            bundleURL: URL(string: "https://enterprise.company.com/apps/enterprise-app.ipa")
        )
        
        // Create deployment options
        let options = DeploymentOptions(
            forceDeployment: true,
            rollbackOnFailure: true,
            maxConcurrentDeployments: 5,
            deploymentTimeout: 300.0
        )
        
        // Deploy app with options
        let result = try await framework.deploy(app: appBundle, options: options)
        
        print("✅ App deployed with custom options!")
        print("📱 Deployment status: \(result.status)")
    }
    
    /// Example: Deploy app to specific devices.
    public static func deployAppToSpecificDevices() async throws {
        // Initialize framework
        let framework = try initializeFramework()
        
        // Create app bundle
        let appBundle = AppBundle(
            identifier: "com.company.enterprise-app",
            version: "1.0.0",
            bundleURL: URL(string: "https://enterprise.company.com/apps/enterprise-app.ipa")
        )
        
        // Create target devices
        let targetDevices = [
            Device(
                identifier: "device-001",
                name: "iPhone 14 Pro - John",
                model: "iPhone14,2",
                osVersion: "16.0",
                deviceInfo: DeviceInfo()
            ),
            Device(
                identifier: "device-002",
                name: "iPhone 14 Pro - Jane",
                model: "iPhone14,2",
                osVersion: "16.0",
                deviceInfo: DeviceInfo()
            )
        ]
        
        // Deploy app to specific devices
        let result = try await framework.deploy(app: appBundle, to: targetDevices)
        
        print("✅ App deployed to specific devices!")
        print("📱 Target devices: \(targetDevices.count)")
        print("✅ Successfully deployed: \(result.deployedDevices.count)")
    }
    
    // MARK: - Device Management
    
    /// Example: Enroll a device in MDM.
    public static func enrollDevice() async throws {
        // Initialize framework
        let framework = try initializeFramework()
        
        // Create device
        let device = Device(
            identifier: "new-device-001",
            name: "iPhone 14 Pro - New Employee",
            model: "iPhone14,2",
            osVersion: "16.0",
            deviceInfo: DeviceInfo(
                serialNumber: "ABCD1234EFGH",
                udid: "00008120-001C25D40C0A002E",
                capabilities: ["camera", "biometric", "cellular"],
                settings: [:]
            )
        )
        
        // Enrollment token (obtained from MDM server)
        let enrollmentToken = "enrollment-token-12345"
        
        // Enroll device
        let result = try await framework.enrollDevice(device, with: enrollmentToken)
        
        print("✅ Device enrolled successfully!")
        print("📱 Device: \(result.device.name)")
        print("📊 Status: \(result.status)")
        print("⏰ Enrolled at: \(result.timestamp)")
    }
    
    /// Example: Remove a device from MDM.
    public static func removeDevice() async throws {
        // Initialize framework
        let framework = try initializeFramework()
        
        // Create device to remove
        let device = Device(
            identifier: "device-to-remove",
            name: "iPhone 14 Pro - Former Employee",
            model: "iPhone14,2",
            osVersion: "16.0",
            deviceInfo: DeviceInfo()
        )
        
        // Remove device
        try await framework.removeDevice(device)
        
        print("✅ Device removed successfully!")
        print("📱 Removed device: \(device.name)")
    }
    
    /// Example: Get all enrolled devices.
    public static func getEnrolledDevices() async throws {
        // Initialize framework
        let framework = try initializeFramework()
        
        // Get enrolled devices
        let devices = try await framework.getEnrolledDevices()
        
        print("📱 Enrolled Devices (\(devices.count) total):")
        
        for device in devices {
            print("  📱 \(device.name)")
            print("    🆔 ID: \(device.identifier)")
            print("    📱 Model: \(device.model)")
            print("    🖥️  OS: \(device.osVersion)")
        }
    }
    
    // MARK: - Analytics
    
    /// Example: Get deployment analytics.
    public static func getDeploymentAnalytics() async throws {
        // Initialize framework
        let framework = try initializeFramework()
        
        // Define time period
        let startDate = Date().addingTimeInterval(-7 * 24 * 3600) // Last 7 days
        let endDate = Date()
        
        // Get analytics
        let analytics = try await framework.getAnalytics(from: startDate, to: endDate)
        
        print("📊 Deployment Analytics (Last 7 days):")
        print("📈 Total Events: \(analytics.totalEvents)")
        print("🚀 Deployment Events: \(analytics.deploymentEvents)")
        print("❌ Error Events: \(analytics.errorEvents)")
        print("👥 Behavior Events: \(analytics.behaviorEvents)")
        print("📅 Period: \(analytics.startDate) to \(analytics.endDate)")
    }
    
    /// Example: Get app-specific analytics.
    public static func getAppAnalytics() async throws {
        // Initialize framework
        let framework = try initializeFramework()
        
        // Get analytics for specific app
        let appIdentifier = "com.company.enterprise-app"
        let analytics = try await framework.getAnalytics(from: Date().addingTimeInterval(-30 * 24 * 3600), to: Date())
        
        // Filter for specific app (in real implementation, use framework.getAppAnalytics)
        let appEvents = analytics.events.filter { $0.appIdentifier == appIdentifier }
        
        print("📊 App Analytics for \(appIdentifier):")
        print("📈 Total Events: \(appEvents.count)")
        print("📅 Period: Last 30 days")
    }
    
    // MARK: - Compliance
    
    /// Example: Generate compliance report.
    public static func generateComplianceReport() async throws {
        // Initialize framework
        let framework = try initializeFramework()
        
        // Generate daily compliance report
        let report = try await framework.generateComplianceReport(
            for: .daily,
            includeAuditLogs: true
        )
        
        print("🔒 Compliance Report:")
        print("📋 Report ID: \(report.reportID)")
        print("📅 Period: \(report.period.description)")
        print("⏰ Generated: \(report.generatedAt)")
        print("📊 Success Rate: \(report.summary.successRate)%")
        print("🔒 Compliance Rate: \(report.summary.complianceRate)%")
        print("🛡️  Security Score: \(report.summary.securityScore)")
        print("⚠️  Risk Level: \(report.summary.riskLevel)")
        print("📝 Audit Logs: \(report.auditLogs.count) entries")
    }
    
    /// Example: Monitor compliance in real-time.
    public static func monitorCompliance() async throws {
        // Initialize framework
        let framework = try initializeFramework()
        
        // Start monitoring data access
        try await framework.complianceService.monitorDataAccess { event in
            print("📊 Data Access Event:")
            print("  👤 User: \(event.userID)")
            print("  📁 Resource: \(event.resource)")
            print("  🔧 Action: \(event.action)")
            print("  ⏰ Time: \(event.timestamp)")
        }
        
        print("✅ Compliance monitoring started")
    }
    
    // MARK: - Error Handling
    
    /// Example: Handle deployment errors.
    public static func handleDeploymentErrors() async {
        do {
            // Initialize framework
            let framework = try initializeFramework()
            
            // Create invalid app bundle
            let invalidApp = AppBundle(
                identifier: "",
                version: nil,
                bundleURL: nil
            )
            
            // Attempt deployment (will fail)
            let result = try await framework.deploy(app: invalidApp)
            
            print("✅ Deployment succeeded: \(result.deploymentID)")
            
        } catch EnterpriseDeploymentError.invalidConfiguration(let message) {
            print("❌ Configuration error: \(message)")
        } catch DeploymentError.invalidAppBundle(let message) {
            print("❌ Invalid app bundle: \(message)")
        } catch DeploymentError.deploymentFailed(let message) {
            print("❌ Deployment failed: \(message)")
        } catch {
            print("❌ Unexpected error: \(error)")
        }
    }
    
    // MARK: - Advanced Usage
    
    /// Example: Batch deployment with rollback.
    public static func batchDeploymentWithRollback() async throws {
        // Initialize framework
        let framework = try initializeFramework()
        
        // Create multiple app bundles
        let appBundles = [
            AppBundle(
                identifier: "com.company.app1",
                version: "1.0.0",
                bundleURL: URL(string: "https://enterprise.company.com/apps/app1.ipa")
            ),
            AppBundle(
                identifier: "com.company.app2",
                version: "2.0.0",
                bundleURL: URL(string: "https://enterprise.company.com/apps/app2.ipa")
            )
        ]
        
        var deploymentResults: [DeploymentResult] = []
        
        // Deploy apps with rollback on failure
        for appBundle in appBundles {
            do {
                let options = DeploymentOptions(
                    forceDeployment: false,
                    rollbackOnFailure: true,
                    maxConcurrentDeployments: 3,
                    deploymentTimeout: 180.0
                )
                
                let result = try await framework.deploy(app: appBundle, options: options)
                deploymentResults.append(result)
                
                print("✅ Deployed \(appBundle.identifier) successfully")
                
            } catch {
                print("❌ Failed to deploy \(appBundle.identifier): \(error)")
                
                // Rollback previous deployments if needed
                for previousResult in deploymentResults {
                    print("🔄 Rolling back \(previousResult.appIdentifier)")
                    // Implement rollback logic here
                }
                
                throw error
            }
        }
        
        print("✅ Batch deployment completed successfully!")
        print("📱 Total deployments: \(deploymentResults.count)")
    }
    
    /// Example: Real-time deployment monitoring.
    public static func realTimeDeploymentMonitoring() async throws {
        // Initialize framework
        let framework = try initializeFramework()
        
        // Create app bundle
        let appBundle = AppBundle(
            identifier: "com.company.monitored-app",
            version: "1.0.0",
            bundleURL: URL(string: "https://enterprise.company.com/apps/monitored-app.ipa")
        )
        
        // Start deployment
        let deploymentTask = Task {
            return try await framework.deploy(app: appBundle)
        }
        
        // Monitor deployment progress
        while !deploymentTask.isCancelled {
            // Get real-time analytics
            let analytics = try await framework.getAnalytics(
                from: Date().addingTimeInterval(-300), // Last 5 minutes
                to: Date()
            )
            
            print("📊 Real-time deployment metrics:")
            print("  📈 Events: \(analytics.totalEvents)")
            print("  🚀 Deployments: \(analytics.deploymentEvents)")
            print("  ❌ Errors: \(analytics.errorEvents)")
            
            // Wait before next check
            try await Task.sleep(nanoseconds: 5_000_000_000) // 5 seconds
        }
        
        // Get final result
        let result = try await deploymentTask.value
        print("✅ Deployment completed: \(result.deploymentID)")
    }
}

// MARK: - Usage Examples

/// Example usage of the framework.
public class UsageExamples {
    
    /// Run all basic usage examples.
    public static func runAllExamples() async {
        print("🚀 iOS Enterprise Deployment Framework - Usage Examples")
        print("=" * 60)
        
        do {
            // Framework initialization
            print("\n📦 Framework Initialization:")
            let framework = try BasicUsageExamples.initializeFramework()
            print("✅ Framework initialized successfully")
            
            // Device management
            print("\n📱 Device Management:")
            let devices = try await framework.getEnrolledDevices()
            print("✅ Found \(devices.count) enrolled devices")
            
            // Analytics
            print("\n📊 Analytics:")
            let analytics = try await framework.getAnalytics(
                from: Date().addingTimeInterval(-24 * 3600),
                to: Date()
            )
            print("✅ Retrieved analytics: \(analytics.totalEvents) events")
            
            // Compliance
            print("\n🔒 Compliance:")
            let report = try await framework.generateComplianceReport(for: .daily)
            print("✅ Generated compliance report: \(report.reportID)")
            
            print("\n✅ All examples completed successfully!")
            
        } catch {
            print("❌ Example failed: \(error)")
        }
    }
    
    /// Run specific example category.
    public static func runExample(_ category: String) async {
        print("🚀 Running \(category) examples...")
        
        do {
            switch category.lowercased() {
            case "deployment":
                try await BasicUsageExamples.deployApp()
            case "devices":
                try await BasicUsageExamples.getEnrolledDevices()
            case "analytics":
                try await BasicUsageExamples.getDeploymentAnalytics()
            case "compliance":
                try await BasicUsageExamples.generateComplianceReport()
            case "errors":
                await BasicUsageExamples.handleDeploymentErrors()
            default:
                print("❌ Unknown category: \(category)")
            }
        } catch {
            print("❌ Example failed: \(error)")
        }
    }
} 