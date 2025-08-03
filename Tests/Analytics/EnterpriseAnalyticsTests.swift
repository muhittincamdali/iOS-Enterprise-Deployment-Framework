//
//  EnterpriseAnalyticsTests.swift
//  iOS Enterprise Deployment Framework
//
//  Created by Muhittin Camdali
//  Copyright © 2023-2024 Muhittin Camdali. All rights reserved.
//

import XCTest
@testable import EnterpriseAnalytics
@testable import EnterpriseDeploymentCore

final class EnterpriseAnalyticsTests: XCTestCase {
    
    var analyticsService: AnalyticsService!
    var mockConfiguration: AnalyticsConfiguration!
    
    override func setUp() {
        super.setUp()
        setupMockConfiguration()
        setupAnalyticsService()
    }
    
    override func tearDown() {
        analyticsService = nil
        mockConfiguration = nil
        super.tearDown()
    }
    
    // MARK: - Setup Methods
    
    private func setupMockConfiguration() {
        mockConfiguration = AnalyticsConfiguration(
            trackingEnabled: true,
            crashReporting: true,
            performanceMonitoring: true,
            behaviorTracking: true
        )
    }
    
    private func setupAnalyticsService() {
        do {
            analyticsService = try AnalyticsService(configuration: mockConfiguration)
        } catch {
            XCTFail("Failed to initialize analytics service: \(error)")
        }
    }
    
    // MARK: - Configuration Tests
    
    func testAnalyticsConfigurationValidation() {
        // Test valid configuration
        XCTAssertNoThrow(try AnalyticsService(configuration: mockConfiguration))
        
        // Test invalid configuration (tracking disabled)
        let invalidConfig = AnalyticsConfiguration(
            trackingEnabled: false,
            crashReporting: true
        )
        
        XCTAssertThrowsError(try AnalyticsService(configuration: invalidConfig)) { error in
            XCTAssertTrue(error is AnalyticsError)
        }
        
        // Test invalid configuration (crash reporting disabled)
        let invalidCrashConfig = AnalyticsConfiguration(
            trackingEnabled: true,
            crashReporting: false
        )
        
        XCTAssertThrowsError(try AnalyticsService(configuration: invalidCrashConfig)) { error in
            XCTAssertTrue(error is AnalyticsError)
        }
    }
    
    func testAnalyticsConfigurationProperties() {
        XCTAssertTrue(mockConfiguration.trackingEnabled)
        XCTAssertTrue(mockConfiguration.crashReporting)
        XCTAssertTrue(mockConfiguration.performanceMonitoring)
        XCTAssertTrue(mockConfiguration.behaviorTracking)
    }
    
    // MARK: - Analytics Tracking Tests
    
    func testTrackDeployment() async throws {
        // Given
        let deploymentResult = createMockDeploymentResult()
        
        // When
        XCTAssertNoThrow(try await analyticsService.trackDeployment(deploymentResult))
    }
    
    func testGetAnalytics() async throws {
        // Given
        let startDate = Date().addingTimeInterval(-86400) // Yesterday
        let endDate = Date()
        
        // When
        let analytics = try await analyticsService.getAnalytics(from: startDate, to: endDate)
        
        // Then
        XCTAssertNotNil(analytics)
        XCTAssertTrue(analytics.totalEvents >= 0)
        XCTAssertNotNil(analytics.startDate)
        XCTAssertNotNil(analytics.endDate)
        XCTAssertNotNil(analytics.events)
    }
    
    func testGetAppAnalytics() async throws {
        // Given
        let appIdentifier = "com.test.app"
        
        // When
        let analytics = try await analyticsService.getAppAnalytics(appIdentifier)
        
        // Then
        XCTAssertNotNil(analytics)
        XCTAssertEqual(analytics.appIdentifier, appIdentifier)
        XCTAssertTrue(analytics.totalDeployments >= 0)
        XCTAssertNotNil(analytics.events)
    }
    
    func testGetDeviceAnalytics() async throws {
        // When
        let analytics = try await analyticsService.getDeviceAnalytics()
        
        // Then
        XCTAssertNotNil(analytics)
        XCTAssertTrue(analytics.totalDevices >= 0)
        XCTAssertNotNil(analytics.deviceTypes)
        XCTAssertNotNil(analytics.osVersions)
        XCTAssertNotNil(analytics.events)
    }
    
    func testGetPerformanceAnalytics() async throws {
        // When
        let analytics = try await analyticsService.getPerformanceAnalytics()
        
        // Then
        XCTAssertNotNil(analytics)
        XCTAssertTrue(analytics.averageDeploymentTime >= 0)
        XCTAssertTrue(analytics.averageSuccessRate >= 0)
        XCTAssertTrue(analytics.averageResponseTime >= 0)
        XCTAssertTrue(analytics.averageMemoryUsage >= 0)
        XCTAssertTrue(analytics.averageNetworkLatency >= 0)
        XCTAssertNotNil(analytics.metrics)
    }
    
    func testTrackUserBehavior() async throws {
        // Given
        let behaviorEvent = createMockBehaviorEvent()
        
        // When
        XCTAssertNoThrow(try await analyticsService.trackUserBehavior(behaviorEvent))
    }
    
    func testTrackError() async throws {
        // Given
        let errorEvent = createMockErrorEvent()
        
        // When
        XCTAssertNoThrow(try await analyticsService.trackError(errorEvent))
    }
    
    // MARK: - Supporting Types Tests
    
    func testAnalyticsDataInitialization() {
        // Given
        let events: [AnalyticsEvent] = [
            createMockDeploymentEvent(),
            createMockBehaviorEvent(),
            createMockErrorEvent()
        ]
        
        let data = AnalyticsData(
            totalEvents: 3,
            deploymentEvents: 1,
            errorEvents: 1,
            behaviorEvents: 1,
            startDate: Date().addingTimeInterval(-86400),
            endDate: Date(),
            events: events
        )
        
        // Then
        XCTAssertEqual(data.totalEvents, 3)
        XCTAssertEqual(data.deploymentEvents, 1)
        XCTAssertEqual(data.errorEvents, 1)
        XCTAssertEqual(data.behaviorEvents, 1)
        XCTAssertNotNil(data.startDate)
        XCTAssertNotNil(data.endDate)
        XCTAssertEqual(data.events.count, 3)
    }
    
    func testAppAnalyticsDataInitialization() {
        // Given
        let events: [AnalyticsEvent] = [
            createMockDeploymentEvent(),
            createMockBehaviorEvent()
        ]
        
        let data = AppAnalyticsData(
            appIdentifier: "com.test.app",
            totalDeployments: 10,
            successfulDeployments: 9,
            failedDeployments: 1,
            averageDeploymentTime: 3.5,
            userEngagement: 0.85,
            events: events
        )
        
        // Then
        XCTAssertEqual(data.appIdentifier, "com.test.app")
        XCTAssertEqual(data.totalDeployments, 10)
        XCTAssertEqual(data.successfulDeployments, 9)
        XCTAssertEqual(data.failedDeployments, 1)
        XCTAssertEqual(data.averageDeploymentTime, 3.5)
        XCTAssertEqual(data.userEngagement, 0.85)
        XCTAssertEqual(data.events.count, 2)
    }
    
    func testDeviceAnalyticsDataInitialization() {
        // Given
        let events = [
            createMockDeviceEvent()
        ]
        
        let data = DeviceAnalyticsData(
            totalDevices: 100,
            activeDevices: 85,
            deviceTypes: ["iPhone": 60, "iPad": 30, "Mac": 10],
            osVersions: ["iOS 16": 70, "iOS 15": 25, "iOS 14": 5],
            averageDeviceHealth: 85.0,
            events: events
        )
        
        // Then
        XCTAssertEqual(data.totalDevices, 100)
        XCTAssertEqual(data.activeDevices, 85)
        XCTAssertEqual(data.deviceTypes.count, 3)
        XCTAssertEqual(data.osVersions.count, 3)
        XCTAssertEqual(data.averageDeviceHealth, 85.0)
        XCTAssertEqual(data.events.count, 1)
    }
    
    func testPerformanceAnalyticsDataInitialization() {
        // Given
        let metrics = [
            PerformanceMetrics(
                deploymentTime: 5.0,
                successRate: 95.0,
                averageDeviceResponseTime: 2.5,
                memoryUsage: 150.0,
                networkLatency: 50.0
            )
        ]
        
        let data = PerformanceAnalyticsData(
            averageDeploymentTime: 5.0,
            averageSuccessRate: 95.0,
            averageResponseTime: 2.5,
            averageMemoryUsage: 150.0,
            averageNetworkLatency: 50.0,
            metrics: metrics
        )
        
        // Then
        XCTAssertEqual(data.averageDeploymentTime, 5.0)
        XCTAssertEqual(data.averageSuccessRate, 95.0)
        XCTAssertEqual(data.averageResponseTime, 2.5)
        XCTAssertEqual(data.averageMemoryUsage, 150.0)
        XCTAssertEqual(data.averageNetworkLatency, 50.0)
        XCTAssertEqual(data.metrics.count, 1)
    }
    
    func testDeploymentAnalyticsEventInitialization() {
        // Given
        let event = DeploymentAnalyticsEvent(
            deploymentID: "deployment-123",
            appIdentifier: "com.test.app",
            status: .success,
            deployedDevices: 10,
            failedDevices: 0,
            timestamp: Date()
        )
        
        // Then
        XCTAssertEqual(event.deploymentID, "deployment-123")
        XCTAssertEqual(event.appIdentifier, "com.test.app")
        XCTAssertEqual(event.status, .success)
        XCTAssertEqual(event.deployedDevices, 10)
        XCTAssertEqual(event.failedDevices, 0)
        XCTAssertNotNil(event.timestamp)
    }
    
    func testUserBehaviorEventInitialization() {
        // Given
        let event = UserBehaviorEvent(
            type: .appLaunch,
            userID: "user-123",
            sessionID: "session-456",
            details: ["screen": "main", "action": "launch"],
            timestamp: Date(),
            appIdentifier: "com.test.app"
        )
        
        // Then
        XCTAssertEqual(event.type, .appLaunch)
        XCTAssertEqual(event.userID, "user-123")
        XCTAssertEqual(event.sessionID, "session-456")
        XCTAssertEqual(event.details.count, 2)
        XCTAssertNotNil(event.timestamp)
        XCTAssertEqual(event.appIdentifier, "com.test.app")
    }
    
    func testErrorEventInitialization() {
        // Given
        let event = ErrorEvent(
            type: .crash,
            message: "App crashed unexpectedly",
            stackTrace: "Stack trace here",
            deviceInfo: DeviceInfo(),
            timestamp: Date(),
            appIdentifier: "com.test.app"
        )
        
        // Then
        XCTAssertEqual(event.type, .crash)
        XCTAssertEqual(event.message, "App crashed unexpectedly")
        XCTAssertEqual(event.stackTrace, "Stack trace here")
        XCTAssertNotNil(event.deviceInfo)
        XCTAssertNotNil(event.timestamp)
        XCTAssertEqual(event.appIdentifier, "com.test.app")
    }
    
    func testDeviceAnalyticsEventInitialization() {
        // Given
        let event = DeviceAnalyticsEvent(
            deviceID: "device-123",
            deviceType: "iPhone",
            osVersion: "16.0",
            isActive: true,
            healthScore: 90.0,
            timestamp: Date()
        )
        
        // Then
        XCTAssertEqual(event.deviceID, "device-123")
        XCTAssertEqual(event.deviceType, "iPhone")
        XCTAssertEqual(event.osVersion, "16.0")
        XCTAssertTrue(event.isActive)
        XCTAssertEqual(event.healthScore, 90.0)
        XCTAssertNotNil(event.timestamp)
    }
    
    func testPerformanceMetricsInitialization() {
        // Given
        let metrics = PerformanceMetrics(
            deploymentTime: 3.5,
            successRate: 98.0,
            averageDeviceResponseTime: 2.0,
            memoryUsage: 125.0,
            networkLatency: 45.0
        )
        
        // Then
        XCTAssertEqual(metrics.deploymentTime, 3.5)
        XCTAssertEqual(metrics.successRate, 98.0)
        XCTAssertEqual(metrics.averageDeviceResponseTime, 2.0)
        XCTAssertEqual(metrics.memoryUsage, 125.0)
        XCTAssertEqual(metrics.networkLatency, 45.0)
    }
    
    func testUserEngagementMetricsInitialization() {
        // Given
        let metrics = UserEngagementMetrics(
            activeUsers: 1000,
            sessionDuration: 15.5,
            featureUsage: ["dashboard": 0.8, "reports": 0.6],
            retentionRate: 0.85
        )
        
        // Then
        XCTAssertEqual(metrics.activeUsers, 1000)
        XCTAssertEqual(metrics.sessionDuration, 15.5)
        XCTAssertEqual(metrics.featureUsage.count, 2)
        XCTAssertEqual(metrics.retentionRate, 0.85)
    }
    
    // MARK: - Error Handling Tests
    
    func testAnalyticsErrorTypes() {
        // Test all analytics error types
        let errors: [AnalyticsError] = [
            .invalidConfiguration("Test config error"),
            .trackingFailed("Test tracking error"),
            .dataRetrievalFailed("Test retrieval error"),
            .dataProcessingFailed("Test processing error"),
            .storageFailed("Test storage error")
        ]
        
        // Verify all errors have descriptions
        for error in errors {
            XCTAssertNotNil(error.errorDescription)
            XCTAssertTrue(error.errorDescription?.contains("error") == true)
        }
    }
    
    func testAnalyticsErrorLocalization() {
        // Test error localization
        let error = AnalyticsError.invalidConfiguration("Configuration is invalid")
        
        XCTAssertNotNil(error.errorDescription)
        XCTAssertTrue(error.errorDescription?.contains("Invalid analytics configuration") == true)
        XCTAssertTrue(error.errorDescription?.contains("Configuration is invalid") == true)
    }
    
    // MARK: - Helper Methods
    
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
    
    private func createMockDeploymentEvent() -> DeploymentAnalyticsEvent {
        return DeploymentAnalyticsEvent(
            deploymentID: "deployment-123",
            appIdentifier: "com.test.app",
            status: .success,
            deployedDevices: 10,
            failedDevices: 0,
            timestamp: Date()
        )
    }
    
    private func createMockBehaviorEvent() -> UserBehaviorEvent {
        return UserBehaviorEvent(
            type: .appLaunch,
            userID: "user-123",
            sessionID: "session-456",
            details: ["screen": "main"],
            timestamp: Date(),
            appIdentifier: "com.test.app"
        )
    }
    
    private func createMockErrorEvent() -> ErrorEvent {
        return ErrorEvent(
            type: .crash,
            message: "Test error",
            stackTrace: nil,
            deviceInfo: nil,
            timestamp: Date(),
            appIdentifier: "com.test.app"
        )
    }
    
    private func createMockDeviceEvent() -> DeviceAnalyticsEvent {
        return DeviceAnalyticsEvent(
            deviceID: "device-123",
            deviceType: "iPhone",
            osVersion: "16.0",
            isActive: true,
            healthScore: 90.0,
            timestamp: Date()
        )
    }
}

// MARK: - Integration Tests

final class AnalyticsIntegrationTests: XCTestCase {
    
    func testEndToEndAnalyticsWorkflow() async throws {
        // Given
        let config = AnalyticsConfiguration(
            trackingEnabled: true,
            crashReporting: true,
            performanceMonitoring: true,
            behaviorTracking: true
        )
        
        let service = try AnalyticsService(configuration: config)
        let deploymentResult = DeploymentResult(
            status: .success,
            appIdentifier: "com.test.app",
            deploymentID: "deployment-123",
            deployedDevices: [],
            failedDevices: [],
            complianceReport: nil,
            analytics: nil,
            timestamp: Date()
        )
        
        // When
        try await service.trackDeployment(deploymentResult)
        let analytics = try await service.getAnalytics(from: Date().addingTimeInterval(-86400), to: Date())
        let appAnalytics = try await service.getAppAnalytics("com.test.app")
        let deviceAnalytics = try await service.getDeviceAnalytics()
        let performanceAnalytics = try await service.getPerformanceAnalytics()
        
        // Then
        XCTAssertNotNil(analytics)
        XCTAssertNotNil(appAnalytics)
        XCTAssertNotNil(deviceAnalytics)
        XCTAssertNotNil(performanceAnalytics)
    }
} 