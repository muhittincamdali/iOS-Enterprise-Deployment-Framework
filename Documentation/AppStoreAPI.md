# App Store API

## Overview

The App Store API provides comprehensive integration with Apple's App Store Connect for automated app submission, release management, and distribution.

## Core Classes

### AppStoreManager

Main class for App Store Connect operations.

```swift
public class AppStoreManager {
    public init(apiKey: String, issuerId: String, keyId: String)
    public func submitApp(_ app: AppStoreApp) async throws -> SubmissionResult
    public func createRelease(_ release: AppStoreRelease) async throws -> ReleaseResult
    public func updateMetadata(_ metadata: AppStoreMetadata) async throws -> MetadataResult
}
```

### AppStoreApp

Represents an App Store application.

```swift
public struct AppStoreApp {
    public let bundleId: String
    public let name: String
    public let version: String
    public let buildNumber: String
    public let platform: Platform
    public let metadata: AppStoreMetadata
}
```

### AppStoreRelease

Represents an App Store release.

```swift
public struct AppStoreRelease {
    public let version: String
    public let buildNumber: String
    public let releaseNotes: [String: String]
    public let phasedRelease: Bool
    public let autoReleaseDate: Date?
    public let complianceInfo: ComplianceInfo
}
```

## Usage Examples

### Submit App to App Store

```swift
let appStoreManager = AppStoreManager(
    apiKey: "YOUR_API_KEY",
    issuerId: "YOUR_ISSUER_ID",
    keyId: "YOUR_KEY_ID"
)

let app = AppStoreApp(
    bundleId: "com.company.app",
    name: "My Enterprise App",
    version: "1.2.3",
    buildNumber: "456",
    platform: .iOS,
    metadata: AppStoreMetadata()
)

let result = try await appStoreManager.submitApp(app)
```

### Create Release

```swift
let release = AppStoreRelease(
    version: "1.2.3",
    buildNumber: "456",
    releaseNotes: [
        "en-US": "Bug fixes and performance improvements",
        "tr-TR": "Hata düzeltmeleri ve performans iyileştirmeleri"
    ],
    phasedRelease: true,
    autoReleaseDate: nil,
    complianceInfo: ComplianceInfo()
)

let releaseResult = try await appStoreManager.createRelease(release)
```

## Metadata Management

### AppStoreMetadata

```swift
public struct AppStoreMetadata {
    public var name: [String: String]
    public var description: [String: String]
    public var keywords: [String: String]
    public var promotionalText: [String: String]
    public var releaseNotes: [String: String]
    public var privacyPolicyUrl: String?
    public var supportUrl: String?
    public var marketingUrl: String?
}
```

### Update App Metadata

```swift
let metadata = AppStoreMetadata()
metadata.name = [
    "en-US": "My Enterprise App",
    "tr-TR": "Kurumsal Uygulamam"
]
metadata.description = [
    "en-US": "Professional enterprise application for iOS",
    "tr-TR": "iOS için profesyonel kurumsal uygulama"
]

let metadataResult = try await appStoreManager.updateMetadata(metadata)
```

## Compliance and Security

### ComplianceInfo

```swift
public struct ComplianceInfo {
    public var exportCompliance: Bool
    public var usesEncryption: Bool
    public var encryptionInfo: EncryptionInfo?
    public var contentRights: ContentRights
}
```

### EncryptionInfo

```swift
public struct EncryptionInfo {
    public var isExempt: Bool
    public var containsProprietaryCryptography: Bool
    public var containsThirdPartyCryptography: Bool
    public var exemptionReason: String?
}
```

## Error Handling

```swift
public enum AppStoreError: Error {
    case authenticationFailed(String)
    case appNotFound(String)
    case submissionFailed(String)
    case metadataError(String)
    case complianceError(String)
    case networkError(Error)
}
```

## Best Practices

1. Always validate metadata before submission
2. Use phased releases for major updates
3. Implement proper error handling
4. Monitor submission status
5. Follow App Store guidelines
6. Test with TestFlight before App Store submission
7. Keep API keys secure
8. Implement retry logic for network failures

## Integration with CI/CD

```swift
public protocol AppStoreCI {
    func submitToAppStore(_ build: Build) async throws -> SubmissionResult
    func createTestFlightRelease(_ build: Build) async throws -> ReleaseResult
    func updateAppMetadata(_ metadata: AppStoreMetadata) async throws -> MetadataResult
}
```

## Analytics and Monitoring

```swift
public protocol AppStoreAnalytics {
    func trackSubmission(_ submission: SubmissionResult)
    func trackRelease(_ release: ReleaseResult)
    func trackMetadataUpdate(_ metadata: MetadataResult)
}
```
