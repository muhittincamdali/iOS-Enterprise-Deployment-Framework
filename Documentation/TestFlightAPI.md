# TestFlight API

## Overview

The TestFlight API provides comprehensive integration with Apple's TestFlight for beta testing, internal distribution, and automated build management.

## Core Classes

### TestFlightManager

Main class for TestFlight operations.

```swift
public class TestFlightManager {
    public init(apiKey: String, issuerId: String, keyId: String)
    public func uploadBuild(_ build: TestFlightBuild) async throws -> UploadResult
    public func createTestFlightRelease(_ release: TestFlightRelease) async throws -> ReleaseResult
    public func addTesters(_ testers: [Tester]) async throws -> TesterResult
    public func removeTesters(_ testers: [Tester]) async throws -> TesterResult
}
```

### TestFlightBuild

Represents a TestFlight build.

```swift
public struct TestFlightBuild {
    public let bundleId: String
    public let version: String
    public let buildNumber: String
    public let platform: Platform
    public let filePath: String
    public let metadata: BuildMetadata
}
```

### TestFlightRelease

Represents a TestFlight release.

```swift
public struct TestFlightRelease {
    public let version: String
    public let buildNumber: String
    public let releaseNotes: [String: String]
    public let testers: [Tester]
    public let groups: [TestGroup]
    public let autoNotifyTesters: Bool
}
```

## Usage Examples

### Upload Build to TestFlight

```swift
let testFlightManager = TestFlightManager(
    apiKey: "YOUR_API_KEY",
    issuerId: "YOUR_ISSUER_ID",
    keyId: "YOUR_KEY_ID"
)

let build = TestFlightBuild(
    bundleId: "com.company.app",
    version: "1.2.3",
    buildNumber: "456",
    platform: .iOS,
    filePath: "/path/to/app.ipa",
    metadata: BuildMetadata()
)

let uploadResult = try await testFlightManager.uploadBuild(build)
```

### Create TestFlight Release

```swift
let release = TestFlightRelease(
    version: "1.2.3",
    buildNumber: "456",
    releaseNotes: [
        "en-US": "New features and bug fixes",
        "tr-TR": "Yeni özellikler ve hata düzeltmeleri"
    ],
    testers: [tester1, tester2],
    groups: [internalGroup, betaGroup],
    autoNotifyTesters: true
)

let releaseResult = try await testFlightManager.createTestFlightRelease(release)
```

## Tester Management

### Tester

```swift
public struct Tester {
    public let email: String
    public let firstName: String?
    public let lastName: String?
    public let groups: [String]
    public let deviceIds: [String]?
}
```

### Add Testers

```swift
let testers = [
    Tester(
        email: "tester1@company.com",
        firstName: "John",
        lastName: "Doe",
        groups: ["Internal", "Beta"],
        deviceIds: nil
    ),
    Tester(
        email: "tester2@company.com",
        firstName: "Jane",
        lastName: "Smith",
        groups: ["Beta"],
        deviceIds: nil
    )
]

let testerResult = try await testFlightManager.addTesters(testers)
```

## Test Groups

### TestGroup

```swift
public struct TestGroup {
    public let name: String
    public let description: String?
    public let testers: [Tester]
    public let autoNotify: Bool
    public let maxTesters: Int?
}
```

### Create Test Groups

```swift
let internalGroup = TestGroup(
    name: "Internal Testers",
    description: "Internal development team",
    testers: internalTesters,
    autoNotify: true,
    maxTesters: 50
)

let betaGroup = TestGroup(
    name: "Beta Testers",
    description: "External beta testers",
    testers: betaTesters,
    autoNotify: false,
    maxTesters: 1000
)
```

## Build Metadata

### BuildMetadata

```swift
public struct BuildMetadata {
    public var whatsNew: [String: String]
    public var feedbackEmail: String?
    public var marketingUrl: String?
    public var privacyPolicyUrl: String?
    public var supportUrl: String?
    public var description: [String: String]
}
```

## Error Handling

```swift
public enum TestFlightError: Error {
    case authenticationFailed(String)
    case buildNotFound(String)
    case uploadFailed(String)
    case testerNotFound(String)
    case groupNotFound(String)
    case networkError(Error)
}
```

## Automated Testing

### TestFlightAutomation

```swift
public protocol TestFlightAutomation {
    func uploadAndTest(_ build: TestFlightBuild) async throws -> TestResult
    func runAutomatedTests(_ tests: [AutomatedTest]) async throws -> TestResult
    func generateTestReport(_ result: TestResult) -> TestReport
}
```

### AutomatedTest

```swift
public struct AutomatedTest {
    public let name: String
    public let testScript: String
    public let deviceTypes: [String]
    public let timeout: TimeInterval
    public let expectedResult: TestExpectation
}
```

## Analytics and Monitoring

```swift
public protocol TestFlightAnalytics {
    func trackBuildUpload(_ result: UploadResult)
    func trackReleaseCreation(_ result: ReleaseResult)
    func trackTesterActivity(_ activity: TesterActivity)
    func generateTestFlightReport() -> TestFlightReport
}
```

## Best Practices

1. Use descriptive build numbers
2. Provide clear release notes
3. Organize testers into logical groups
4. Monitor build processing status
5. Implement automated testing
6. Track tester feedback
7. Maintain build history
8. Follow TestFlight guidelines

## Integration with CI/CD

```swift
public protocol TestFlightCI {
    func uploadToTestFlight(_ build: Build) async throws -> UploadResult
    func createTestFlightRelease(_ build: Build) async throws -> ReleaseResult
    func notifyTesters(_ release: TestFlightRelease) async throws -> NotificationResult
}
```

## Security and Compliance

- Secure API key management
- Tester data protection
- Build integrity validation
- Access control and permissions
- Audit logging
- Compliance with Apple guidelines
