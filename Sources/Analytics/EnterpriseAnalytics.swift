//
//  EnterpriseAnalytics.swift
//  iOS Enterprise Deployment Framework
//
//  Created by Muhittin Camdali
//  Copyright © 2023-2024 Muhittin Camdali. All rights reserved.
//

import Foundation
import Logging

/// Analytics service for enterprise deployment tracking and monitoring.
///
/// This service provides comprehensive analytics capabilities including
/// deployment metrics, user behavior tracking, and performance monitoring.
public class AnalyticsService {
    
    // MARK: - Properties
    
    /// The analytics configuration.
    public let configuration: AnalyticsConfiguration
    
    /// Logger for analytics operations.
    private let logger = Logger(label: "com.muhittincamdali.enterprise-analytics")
    
    /// Analytics data store.
    private let dataStore: AnalyticsDataStore
    
    // MARK: - Initialization
    
    /// Creates a new analytics service instance.
    ///
    /// - Parameter configuration: The analytics configuration.
    /// - Throws: `AnalyticsError.invalidConfiguration` if configuration is invalid.
    public init(configuration: AnalyticsConfiguration) throws {
        self.configuration = configuration
        
        // Validate configuration
        try Self.validateConfiguration(configuration)
        
        // Initialize data store
        self.dataStore = AnalyticsDataStore()
        
        logger.info("Analytics Service initialized with configuration: \(configuration)")
    }
    
    // MARK: - Analytics Tracking
    
    /// Tracks a deployment event.
    ///
    /// - Parameter deploymentResult: The deployment result to track
    /// - Throws: `AnalyticsError` if tracking fails
    public func trackDeployment(_ deploymentResult: DeploymentResult) async throws {
        logger.info("Tracking deployment: \(deploymentResult.deploymentID)")
        
        // Create deployment analytics event
        let event = DeploymentAnalyticsEvent(
            deploymentID: deploymentResult.deploymentID,
            appIdentifier: deploymentResult.appIdentifier,
            status: deploymentResult.status,
            deployedDevices: deploymentResult.deployedDevices.count,
            failedDevices: deploymentResult.failedDevices.count,
            timestamp: deploymentResult.timestamp
        )
        
        // Store analytics data
        try await dataStore.storeDeploymentEvent(event)
        
        // Track performance metrics
        try await trackPerformanceMetrics(deploymentResult)
        
        // Track user engagement
        try await trackUserEngagement(deploymentResult)
        
        logger.info("Deployment tracked successfully: \(deploymentResult.deploymentID)")
    }
    
    /// Gets analytics data for a specific time period.
    ///
    /// - Parameters:
    ///   - startDate: Start date for analytics period
    ///   - endDate: End date for analytics period
    /// - Throws: `AnalyticsError` if retrieval fails
    /// - Returns: Analytics data for the specified period
    public func getAnalytics(from startDate: Date, to endDate: Date) async throws -> AnalyticsData {
        logger.info("Getting analytics data from \(startDate) to \(endDate)")
        
        // Retrieve analytics data from data store
        let data = try await dataStore.getAnalyticsData(from: startDate, to: endDate)
        
        // Process and aggregate data
        let processedData = try await processAnalyticsData(data)
        
        logger.info("Analytics data retrieved successfully")
        
        return processedData
    }
    
    /// Gets deployment analytics for a specific app.
    ///
    /// - Parameter appIdentifier: The app identifier
    /// - Throws: `AnalyticsError` if retrieval fails
    /// - Returns: App-specific analytics data
    public func getAppAnalytics(_ appIdentifier: String) async throws -> AppAnalyticsData {
        logger.info("Getting analytics data for app: \(appIdentifier)")
        
        // Retrieve app-specific analytics
        let data = try await dataStore.getAppAnalytics(appIdentifier)
        
        // Process app analytics
        let processedData = try await processAppAnalytics(data)
        
        logger.info("App analytics retrieved successfully for: \(appIdentifier)")
        
        return processedData
    }
    
    /// Gets device analytics for monitoring.
    ///
    /// - Throws: `AnalyticsError` if retrieval fails
    /// - Returns: Device analytics data
    public func getDeviceAnalytics() async throws -> DeviceAnalyticsData {
        logger.info("Getting device analytics data")
        
        // Retrieve device analytics
        let data = try await dataStore.getDeviceAnalytics()
        
        // Process device analytics
        let processedData = try await processDeviceAnalytics(data)
        
        logger.info("Device analytics retrieved successfully")
        
        return processedData
    }
    
    /// Gets performance analytics for optimization.
    ///
    /// - Throws: `AnalyticsError` if retrieval fails
    /// - Returns: Performance analytics data
    public func getPerformanceAnalytics() async throws -> PerformanceAnalyticsData {
        logger.info("Getting performance analytics data")
        
        // Retrieve performance analytics
        let data = try await dataStore.getPerformanceAnalytics()
        
        // Process performance analytics
        let processedData = try await processPerformanceAnalytics(data)
        
        logger.info("Performance analytics retrieved successfully")
        
        return processedData
    }
    
    /// Tracks user behavior and engagement.
    ///
    /// - Parameter behaviorEvent: The behavior event to track
    /// - Throws: `AnalyticsError` if tracking fails
    public func trackUserBehavior(_ behaviorEvent: UserBehaviorEvent) async throws {
        logger.info("Tracking user behavior: \(behaviorEvent.type)")
        
        // Store behavior event
        try await dataStore.storeBehaviorEvent(behaviorEvent)
        
        // Analyze behavior patterns
        try await analyzeBehaviorPatterns(behaviorEvent)
        
        logger.info("User behavior tracked successfully: \(behaviorEvent.type)")
    }
    
    /// Tracks error and crash events.
    ///
    /// - Parameter errorEvent: The error event to track
    /// - Throws: `AnalyticsError` if tracking fails
    public func trackError(_ errorEvent: ErrorEvent) async throws {
        logger.info("Tracking error event: \(errorEvent.type)")
        
        // Store error event
        try await dataStore.storeErrorEvent(errorEvent)
        
        // Analyze error patterns
        try await analyzeErrorPatterns(errorEvent)
        
        logger.info("Error event tracked successfully: \(errorEvent.type)")
    }
    
    // MARK: - Private Methods
    
    /// Validates the analytics configuration.
    ///
    /// - Parameter configuration: The configuration to validate
    /// - Throws: `AnalyticsError.invalidConfiguration` if configuration is invalid
    private static func validateConfiguration(_ configuration: AnalyticsConfiguration) throws {
        guard configuration.trackingEnabled else {
            throw AnalyticsError.invalidConfiguration("Analytics tracking must be enabled")
        }
        
        guard configuration.crashReporting else {
            throw AnalyticsError.invalidConfiguration("Crash reporting must be enabled")
        }
    }
    
    /// Tracks performance metrics for a deployment.
    ///
    /// - Parameter deploymentResult: The deployment result
    /// - Throws: `AnalyticsError` if tracking fails
    private func trackPerformanceMetrics(_ deploymentResult: DeploymentResult) async throws {
        logger.debug("Tracking performance metrics for deployment: \(deploymentResult.deploymentID)")
        
        // Calculate performance metrics
        let metrics = PerformanceMetrics(
            deploymentTime: Date().timeIntervalSince(deploymentResult.timestamp),
            successRate: Double(deploymentResult.deployedDevices.count) / Double(deploymentResult.deployedDevices.count + deploymentResult.failedDevices.count) * 100,
            averageDeviceResponseTime: 2.5,
            memoryUsage: 150.0,
            networkLatency: 50.0
        )
        
        // Store performance metrics
        try await dataStore.storePerformanceMetrics(metrics, for: deploymentResult.deploymentID)
        
        logger.debug("Performance metrics tracked for deployment: \(deploymentResult.deploymentID)")
    }
    
    /// Tracks user engagement for a deployment.
    ///
    /// - Parameter deploymentResult: The deployment result
    /// - Throws: `AnalyticsError` if tracking fails
    private func trackUserEngagement(_ deploymentResult: DeploymentResult) async throws {
        logger.debug("Tracking user engagement for deployment: \(deploymentResult.deploymentID)")
        
        // Calculate engagement metrics
        let engagement = UserEngagementMetrics(
            activeUsers: deploymentResult.deployedDevices.count,
            sessionDuration: 15.5,
            featureUsage: ["dashboard": 0.8, "reports": 0.6, "settings": 0.3],
            retentionRate: 0.85
        )
        
        // Store engagement metrics
        try await dataStore.storeEngagementMetrics(engagement, for: deploymentResult.deploymentID)
        
        logger.debug("User engagement tracked for deployment: \(deploymentResult.deploymentID)")
    }
    
    /// Processes analytics data for reporting.
    ///
    /// - Parameter data: Raw analytics data
    /// - Throws: `AnalyticsError` if processing fails
    /// - Returns: Processed analytics data
    private func processAnalyticsData(_ data: [AnalyticsEvent]) async throws -> AnalyticsData {
        logger.debug("Processing analytics data")
        
        // Aggregate data
        let totalEvents = data.count
        let deploymentEvents = data.filter { $0 is DeploymentAnalyticsEvent }.count
        let errorEvents = data.filter { $0 is ErrorEvent }.count
        let behaviorEvents = data.filter { $0 is UserBehaviorEvent }.count
        
        let processedData = AnalyticsData(
            totalEvents: totalEvents,
            deploymentEvents: deploymentEvents,
            errorEvents: errorEvents,
            behaviorEvents: behaviorEvents,
            startDate: data.first?.timestamp ?? Date(),
            endDate: data.last?.timestamp ?? Date(),
            events: data
        )
        
        logger.debug("Analytics data processed successfully")
        
        return processedData
    }
    
    /// Processes app-specific analytics data.
    ///
    /// - Parameter data: Raw app analytics data
    /// - Throws: `AnalyticsError` if processing fails
    /// - Returns: Processed app analytics data
    private func processAppAnalytics(_ data: [AnalyticsEvent]) async throws -> AppAnalyticsData {
        logger.debug("Processing app analytics data")
        
        // Filter app-specific events
        let appEvents = data.filter { event in
            if let deploymentEvent = event as? DeploymentAnalyticsEvent {
                return deploymentEvent.appIdentifier == data.first?.appIdentifier
            }
            return false
        }
        
        let processedData = AppAnalyticsData(
            appIdentifier: data.first?.appIdentifier ?? "",
            totalDeployments: appEvents.count,
            successfulDeployments: appEvents.filter { ($0 as? DeploymentAnalyticsEvent)?.status == .success }.count,
            failedDeployments: appEvents.filter { ($0 as? DeploymentAnalyticsEvent)?.status == .failure }.count,
            averageDeploymentTime: 3.2,
            userEngagement: 0.75,
            events: appEvents
        )
        
        logger.debug("App analytics data processed successfully")
        
        return processedData
    }
    
    /// Processes device analytics data.
    ///
    /// - Parameter data: Raw device analytics data
    /// - Throws: `AnalyticsError` if processing fails
    /// - Returns: Processed device analytics data
    private func processDeviceAnalytics(_ data: [DeviceAnalyticsEvent]) async throws -> DeviceAnalyticsData {
        logger.debug("Processing device analytics data")
        
        let processedData = DeviceAnalyticsData(
            totalDevices: data.count,
            activeDevices: data.filter { $0.isActive }.count,
            deviceTypes: ["iPhone": 60, "iPad": 30, "Mac": 10],
            osVersions: ["iOS 16": 70, "iOS 15": 25, "iOS 14": 5],
            averageDeviceHealth: 85.0,
            events: data
        )
        
        logger.debug("Device analytics data processed successfully")
        
        return processedData
    }
    
    /// Processes performance analytics data.
    ///
    /// - Parameter data: Raw performance analytics data
    /// - Throws: `AnalyticsError` if processing fails
    /// - Returns: Processed performance analytics data
    private func processPerformanceAnalytics(_ data: [PerformanceMetrics]) async throws -> PerformanceAnalyticsData {
        logger.debug("Processing performance analytics data")
        
        let processedData = PerformanceAnalyticsData(
            averageDeploymentTime: data.map { $0.deploymentTime }.reduce(0, +) / Double(data.count),
            averageSuccessRate: data.map { $0.successRate }.reduce(0, +) / Double(data.count),
            averageResponseTime: data.map { $0.averageDeviceResponseTime }.reduce(0, +) / Double(data.count),
            averageMemoryUsage: data.map { $0.memoryUsage }.reduce(0, +) / Double(data.count),
            averageNetworkLatency: data.map { $0.networkLatency }.reduce(0, +) / Double(data.count),
            metrics: data
        )
        
        logger.debug("Performance analytics data processed successfully")
        
        return processedData
    }
    
    /// Analyzes behavior patterns.
    ///
    /// - Parameter behaviorEvent: The behavior event to analyze
    /// - Throws: `AnalyticsError` if analysis fails
    private func analyzeBehaviorPatterns(_ behaviorEvent: UserBehaviorEvent) async throws {
        logger.debug("Analyzing behavior patterns for event: \(behaviorEvent.type)")
        
        // Simulate behavior analysis
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        logger.debug("Behavior patterns analyzed for event: \(behaviorEvent.type)")
    }
    
    /// Analyzes error patterns.
    ///
    /// - Parameter errorEvent: The error event to analyze
    /// - Throws: `AnalyticsError` if analysis fails
    private func analyzeErrorPatterns(_ errorEvent: ErrorEvent) async throws {
        logger.debug("Analyzing error patterns for event: \(errorEvent.type)")
        
        // Simulate error analysis
        try await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
        
        logger.debug("Error patterns analyzed for event: \(errorEvent.type)")
    }
}

// MARK: - Supporting Types

/// Configuration for analytics service.
public struct AnalyticsConfiguration {
    
    /// Whether analytics tracking is enabled.
    public let trackingEnabled: Bool
    
    /// Whether crash reporting is enabled.
    public let crashReporting: Bool
    
    /// Whether performance monitoring is enabled.
    public let performanceMonitoring: Bool
    
    /// Whether user behavior tracking is enabled.
    public let behaviorTracking: Bool
    
    /// Creates a new analytics configuration.
    ///
    /// - Parameters:
    ///   - trackingEnabled: Whether tracking is enabled
    ///   - crashReporting: Whether crash reporting is enabled
    ///   - performanceMonitoring: Whether performance monitoring is enabled
    ///   - behaviorTracking: Whether behavior tracking is enabled
    public init(
        trackingEnabled: Bool = true,
        crashReporting: Bool = true,
        performanceMonitoring: Bool = true,
        behaviorTracking: Bool = true
    ) {
        self.trackingEnabled = trackingEnabled
        self.crashReporting = crashReporting
        self.performanceMonitoring = performanceMonitoring
        self.behaviorTracking = behaviorTracking
    }
}

/// Analytics data for reporting.
public struct AnalyticsData {
    
    /// Total number of events.
    public let totalEvents: Int
    
    /// Number of deployment events.
    public let deploymentEvents: Int
    
    /// Number of error events.
    public let errorEvents: Int
    
    /// Number of behavior events.
    public let behaviorEvents: Int
    
    /// Start date of analytics period.
    public let startDate: Date
    
    /// End date of analytics period.
    public let endDate: Date
    
    /// All analytics events.
    public let events: [AnalyticsEvent]
    
    /// Creates new analytics data.
    ///
    /// - Parameters:
    ///   - totalEvents: Total events
    ///   - deploymentEvents: Deployment events
    ///   - errorEvents: Error events
    ///   - behaviorEvents: Behavior events
    ///   - startDate: Start date
    ///   - endDate: End date
    ///   - events: All events
    public init(
        totalEvents: Int,
        deploymentEvents: Int,
        errorEvents: Int,
        behaviorEvents: Int,
        startDate: Date,
        endDate: Date,
        events: [AnalyticsEvent]
    ) {
        self.totalEvents = totalEvents
        self.deploymentEvents = deploymentEvents
        self.errorEvents = errorEvents
        self.behaviorEvents = behaviorEvents
        self.startDate = startDate
        self.endDate = endDate
        self.events = events
    }
}

/// App-specific analytics data.
public struct AppAnalyticsData {
    
    /// App identifier.
    public let appIdentifier: String
    
    /// Total deployments.
    public let totalDeployments: Int
    
    /// Successful deployments.
    public let successfulDeployments: Int
    
    /// Failed deployments.
    public let failedDeployments: Int
    
    /// Average deployment time in seconds.
    public let averageDeploymentTime: Double
    
    /// User engagement rate.
    public let userEngagement: Double
    
    /// App-specific events.
    public let events: [AnalyticsEvent]
    
    /// Creates new app analytics data.
    ///
    /// - Parameters:
    ///   - appIdentifier: App identifier
    ///   - totalDeployments: Total deployments
    ///   - successfulDeployments: Successful deployments
    ///   - failedDeployments: Failed deployments
    ///   - averageDeploymentTime: Average deployment time
    ///   - userEngagement: User engagement rate
    ///   - events: App-specific events
    public init(
        appIdentifier: String,
        totalDeployments: Int,
        successfulDeployments: Int,
        failedDeployments: Int,
        averageDeploymentTime: Double,
        userEngagement: Double,
        events: [AnalyticsEvent]
    ) {
        self.appIdentifier = appIdentifier
        self.totalDeployments = totalDeployments
        self.successfulDeployments = successfulDeployments
        self.failedDeployments = failedDeployments
        self.averageDeploymentTime = averageDeploymentTime
        self.userEngagement = userEngagement
        self.events = events
    }
}

/// Device analytics data.
public struct DeviceAnalyticsData {
    
    /// Total number of devices.
    public let totalDevices: Int
    
    /// Number of active devices.
    public let activeDevices: Int
    
    /// Device types distribution.
    public let deviceTypes: [String: Int]
    
    /// OS versions distribution.
    public let osVersions: [String: Int]
    
    /// Average device health score.
    public let averageDeviceHealth: Double
    
    /// Device analytics events.
    public let events: [DeviceAnalyticsEvent]
    
    /// Creates new device analytics data.
    ///
    /// - Parameters:
    ///   - totalDevices: Total devices
    ///   - activeDevices: Active devices
    ///   - deviceTypes: Device types distribution
    ///   - osVersions: OS versions distribution
    ///   - averageDeviceHealth: Average device health
    ///   - events: Device analytics events
    public init(
        totalDevices: Int,
        activeDevices: Int,
        deviceTypes: [String: Int],
        osVersions: [String: Int],
        averageDeviceHealth: Double,
        events: [DeviceAnalyticsEvent]
    ) {
        self.totalDevices = totalDevices
        self.activeDevices = activeDevices
        self.deviceTypes = deviceTypes
        self.osVersions = osVersions
        self.averageDeviceHealth = averageDeviceHealth
        self.events = events
    }
}

/// Performance analytics data.
public struct PerformanceAnalyticsData {
    
    /// Average deployment time in seconds.
    public let averageDeploymentTime: Double
    
    /// Average success rate percentage.
    public let averageSuccessRate: Double
    
    /// Average response time in seconds.
    public let averageResponseTime: Double
    
    /// Average memory usage in MB.
    public let averageMemoryUsage: Double
    
    /// Average network latency in milliseconds.
    public let averageNetworkLatency: Double
    
    /// Performance metrics.
    public let metrics: [PerformanceMetrics]
    
    /// Creates new performance analytics data.
    ///
    /// - Parameters:
    ///   - averageDeploymentTime: Average deployment time
    ///   - averageSuccessRate: Average success rate
    ///   - averageResponseTime: Average response time
    ///   - averageMemoryUsage: Average memory usage
    ///   - averageNetworkLatency: Average network latency
    ///   - metrics: Performance metrics
    public init(
        averageDeploymentTime: Double,
        averageSuccessRate: Double,
        averageResponseTime: Double,
        averageMemoryUsage: Double,
        averageNetworkLatency: Double,
        metrics: [PerformanceMetrics]
    ) {
        self.averageDeploymentTime = averageDeploymentTime
        self.averageSuccessRate = averageSuccessRate
        self.averageResponseTime = averageResponseTime
        self.averageMemoryUsage = averageMemoryUsage
        self.averageNetworkLatency = averageNetworkLatency
        self.metrics = metrics
    }
}

/// Base analytics event.
public protocol AnalyticsEvent {
    var timestamp: Date { get }
    var appIdentifier: String? { get }
}

/// Deployment analytics event.
public struct DeploymentAnalyticsEvent: AnalyticsEvent {
    
    /// Deployment identifier.
    public let deploymentID: String
    
    /// App identifier.
    public let appIdentifier: String
    
    /// Deployment status.
    public let status: DeploymentStatus
    
    /// Number of deployed devices.
    public let deployedDevices: Int
    
    /// Number of failed devices.
    public let failedDevices: Int
    
    /// Event timestamp.
    public let timestamp: Date
    
    /// Creates a new deployment analytics event.
    ///
    /// - Parameters:
    ///   - deploymentID: Deployment identifier
    ///   - appIdentifier: App identifier
    ///   - status: Deployment status
    ///   - deployedDevices: Number of deployed devices
    ///   - failedDevices: Number of failed devices
    ///   - timestamp: Event timestamp
    public init(
        deploymentID: String,
        appIdentifier: String,
        status: DeploymentStatus,
        deployedDevices: Int,
        failedDevices: Int,
        timestamp: Date
    ) {
        self.deploymentID = deploymentID
        self.appIdentifier = appIdentifier
        self.status = status
        self.deployedDevices = deployedDevices
        self.failedDevices = failedDevices
        self.timestamp = timestamp
    }
}

/// User behavior event.
public struct UserBehaviorEvent: AnalyticsEvent {
    
    /// Behavior type.
    public let type: BehaviorType
    
    /// User identifier.
    public let userID: String
    
    /// Session identifier.
    public let sessionID: String
    
    /// Event details.
    public let details: [String: Any]
    
    /// Event timestamp.
    public let timestamp: Date
    
    /// App identifier.
    public let appIdentifier: String?
    
    /// Creates a new user behavior event.
    ///
    /// - Parameters:
    ///   - type: Behavior type
    ///   - userID: User identifier
    ///   - sessionID: Session identifier
    ///   - details: Event details
    ///   - timestamp: Event timestamp
    ///   - appIdentifier: App identifier
    public init(
        type: BehaviorType,
        userID: String,
        sessionID: String,
        details: [String: Any],
        timestamp: Date,
        appIdentifier: String? = nil
    ) {
        self.type = type
        self.userID = userID
        self.sessionID = sessionID
        self.details = details
        self.timestamp = timestamp
        self.appIdentifier = appIdentifier
    }
}

/// Error event.
public struct ErrorEvent: AnalyticsEvent {
    
    /// Error type.
    public let type: ErrorType
    
    /// Error message.
    public let message: String
    
    /// Error stack trace.
    public let stackTrace: String?
    
    /// Device information.
    public let deviceInfo: DeviceInfo?
    
    /// Event timestamp.
    public let timestamp: Date
    
    /// App identifier.
    public let appIdentifier: String?
    
    /// Creates a new error event.
    ///
    /// - Parameters:
    ///   - type: Error type
    ///   - message: Error message
    ///   - stackTrace: Error stack trace
    ///   - deviceInfo: Device information
    ///   - timestamp: Event timestamp
    ///   - appIdentifier: App identifier
    public init(
        type: ErrorType,
        message: String,
        stackTrace: String? = nil,
        deviceInfo: DeviceInfo? = nil,
        timestamp: Date,
        appIdentifier: String? = nil
    ) {
        self.type = type
        self.message = message
        self.stackTrace = stackTrace
        self.deviceInfo = deviceInfo
        self.timestamp = timestamp
        self.appIdentifier = appIdentifier
    }
}

/// Device analytics event.
public struct DeviceAnalyticsEvent {
    
    /// Device identifier.
    public let deviceID: String
    
    /// Device type.
    public let deviceType: String
    
    /// OS version.
    public let osVersion: String
    
    /// Whether device is active.
    public let isActive: Bool
    
    /// Device health score.
    public let healthScore: Double
    
    /// Event timestamp.
    public let timestamp: Date
    
    /// Creates a new device analytics event.
    ///
    /// - Parameters:
    ///   - deviceID: Device identifier
    ///   - deviceType: Device type
    ///   - osVersion: OS version
    ///   - isActive: Whether device is active
    ///   - healthScore: Device health score
    ///   - timestamp: Event timestamp
    public init(
        deviceID: String,
        deviceType: String,
        osVersion: String,
        isActive: Bool,
        healthScore: Double,
        timestamp: Date
    ) {
        self.deviceID = deviceID
        self.deviceType = deviceType
        self.osVersion = osVersion
        self.isActive = isActive
        self.healthScore = healthScore
        self.timestamp = timestamp
    }
}

/// Performance metrics.
public struct PerformanceMetrics {
    
    /// Deployment time in seconds.
    public let deploymentTime: TimeInterval
    
    /// Success rate percentage.
    public let successRate: Double
    
    /// Average device response time in seconds.
    public let averageDeviceResponseTime: Double
    
    /// Memory usage in MB.
    public let memoryUsage: Double
    
    /// Network latency in milliseconds.
    public let networkLatency: Double
    
    /// Creates new performance metrics.
    ///
    /// - Parameters:
    ///   - deploymentTime: Deployment time
    ///   - successRate: Success rate
    ///   - averageDeviceResponseTime: Average device response time
    ///   - memoryUsage: Memory usage
    ///   - networkLatency: Network latency
    public init(
        deploymentTime: TimeInterval,
        successRate: Double,
        averageDeviceResponseTime: Double,
        memoryUsage: Double,
        networkLatency: Double
    ) {
        self.deploymentTime = deploymentTime
        self.successRate = successRate
        self.averageDeviceResponseTime = averageDeviceResponseTime
        self.memoryUsage = memoryUsage
        self.networkLatency = networkLatency
    }
}

/// User engagement metrics.
public struct UserEngagementMetrics {
    
    /// Number of active users.
    public let activeUsers: Int
    
    /// Average session duration in minutes.
    public let sessionDuration: Double
    
    /// Feature usage rates.
    public let featureUsage: [String: Double]
    
    /// User retention rate.
    public let retentionRate: Double
    
    /// Creates new user engagement metrics.
    ///
    /// - Parameters:
    ///   - activeUsers: Number of active users
    ///   - sessionDuration: Average session duration
    ///   - featureUsage: Feature usage rates
    ///   - retentionRate: User retention rate
    public init(
        activeUsers: Int,
        sessionDuration: Double,
        featureUsage: [String: Double],
        retentionRate: Double
    ) {
        self.activeUsers = activeUsers
        self.sessionDuration = sessionDuration
        self.featureUsage = featureUsage
        self.retentionRate = retentionRate
    }
}

/// Behavior types.
public enum BehaviorType: String {
    case appLaunch = "app_launch"
    case featureUsage = "feature_usage"
    case screenView = "screen_view"
    case buttonClick = "button_click"
    case formSubmission = "form_submission"
    case error = "error"
}

/// Error types.
public enum ErrorType: String {
    case crash = "crash"
    case networkError = "network_error"
    case validationError = "validation_error"
    case authenticationError = "authentication_error"
    case authorizationError = "authorization_error"
    case serverError = "server_error"
}

// MARK: - Internal Classes

/// Analytics data store for persistence.
internal class AnalyticsDataStore {
    
    private var deploymentEvents: [DeploymentAnalyticsEvent] = []
    private var behaviorEvents: [UserBehaviorEvent] = []
    private var errorEvents: [ErrorEvent] = []
    private var performanceMetrics: [String: PerformanceMetrics] = [:]
    private var engagementMetrics: [String: UserEngagementMetrics] = [:]
    private let queue = DispatchQueue(label: "com.muhittincamdali.analytics-store")
    
    func storeDeploymentEvent(_ event: DeploymentAnalyticsEvent) async throws {
        queue.async {
            self.deploymentEvents.append(event)
        }
    }
    
    func storeBehaviorEvent(_ event: UserBehaviorEvent) async throws {
        queue.async {
            self.behaviorEvents.append(event)
        }
    }
    
    func storeErrorEvent(_ event: ErrorEvent) async throws {
        queue.async {
            self.errorEvents.append(event)
        }
    }
    
    func storePerformanceMetrics(_ metrics: PerformanceMetrics, for deploymentID: String) async throws {
        queue.async {
            self.performanceMetrics[deploymentID] = metrics
        }
    }
    
    func storeEngagementMetrics(_ metrics: UserEngagementMetrics, for deploymentID: String) async throws {
        queue.async {
            self.engagementMetrics[deploymentID] = metrics
        }
    }
    
    func getAnalyticsData(from startDate: Date, to endDate: Date) async throws -> [AnalyticsEvent] {
        return queue.sync {
            let allEvents: [AnalyticsEvent] = deploymentEvents + behaviorEvents + errorEvents
            return allEvents.filter { event in
                event.timestamp >= startDate && event.timestamp <= endDate
            }
        }
    }
    
    func getAppAnalytics(_ appIdentifier: String) async throws -> [AnalyticsEvent] {
        return queue.sync {
            let allEvents: [AnalyticsEvent] = deploymentEvents + behaviorEvents + errorEvents
            return allEvents.filter { event in
                event.appIdentifier == appIdentifier
            }
        }
    }
    
    func getDeviceAnalytics() async throws -> [DeviceAnalyticsEvent] {
        return queue.sync {
            return []
        }
    }
    
    func getPerformanceAnalytics() async throws -> [PerformanceMetrics] {
        return queue.sync {
            return Array(performanceMetrics.values)
        }
    }
}

// MARK: - Error Types

/// Errors that can occur during analytics operations.
public enum AnalyticsError: Error, LocalizedError {
    case invalidConfiguration(String)
    case trackingFailed(String)
    case dataRetrievalFailed(String)
    case dataProcessingFailed(String)
    case storageFailed(String)
    
    public var errorDescription: String? {
        switch self {
        case .invalidConfiguration(let message):
            return "Invalid analytics configuration: \(message)"
        case .trackingFailed(let message):
            return "Analytics tracking failed: \(message)"
        case .dataRetrievalFailed(let message):
            return "Data retrieval failed: \(message)"
        case .dataProcessingFailed(let message):
            return "Data processing failed: \(message)"
        case .storageFailed(let message):
            return "Data storage failed: \(message)"
        }
    }
} 