# Installation Guide

This guide will help you install and set up the iOS Enterprise Deployment Framework in your project.

## Prerequisites

Before installing the framework, ensure you have the following:

- **Xcode 15.0+** - Latest Xcode version
- **Swift 5.9+** - Latest Swift version
- **iOS 15.0+** - Minimum iOS deployment target
- **macOS 12.0+** - Minimum macOS deployment target (for CLI tools)
- **Git** - For version control
- **CocoaPods** (optional) - For dependency management

## Installation Methods

### Swift Package Manager (Recommended)

The iOS Enterprise Deployment Framework is available through Swift Package Manager, which is the recommended installation method.

#### 1. Add Package Dependency

In Xcode:
1. Go to **File** → **Add Package Dependencies**
2. Enter the package URL: `https://github.com/muhittincamdali/iOS-Enterprise-Deployment-Framework.git`
3. Click **Add Package**
4. Select the modules you want to use:
   - `EnterpriseDeploymentCore` - Core framework
   - `EnterpriseMDM` - MDM integration
   - `EnterpriseDistribution` - App distribution
   - `EnterpriseCompliance` - Compliance features
   - `EnterpriseAnalytics` - Analytics capabilities
   - `EnterpriseDeploymentCLI` - Command-line tools

#### 2. Add to Target

1. Select your target in Xcode
2. Go to **General** → **Frameworks, Libraries, and Embedded Content**
3. Click the **+** button
4. Add the framework modules you selected

#### 3. Import in Code

```swift
import EnterpriseDeploymentCore
import EnterpriseMDM
import EnterpriseDistribution
import EnterpriseCompliance
import EnterpriseAnalytics
```

### Manual Installation

If you prefer to install manually:

#### 1. Clone Repository

```bash
git clone https://github.com/muhittincamdali/iOS-Enterprise-Deployment-Framework.git
cd iOS-Enterprise-Deployment-Framework
```

#### 2. Build Framework

```bash
swift build
```

#### 3. Add to Project

1. Drag the built framework files into your Xcode project
2. Ensure the framework is linked to your target
3. Import the modules in your code

## Configuration

### 1. Basic Configuration

After installation, you need to configure the framework:

```swift
import EnterpriseDeploymentCore

// Create MDM configuration
let mdmConfig = MDMConfiguration(
    serverURL: "https://your-mdm-server.com",
    organizationID: "your-org-id",
    authToken: "your-auth-token"
)

// Create distribution configuration
let distributionConfig = DistributionConfiguration(
    appStoreURL: "https://your-enterprise-store.com/apps",
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
let deployment = try EnterpriseDeployment(configuration: config)
```

### 2. Environment Setup

#### Development Environment

For development, you can use mock configurations:

```swift
let devConfig = EnterpriseDeploymentConfiguration(
    mdmServerURL: "https://dev-mdm.company.com",
    appStoreURL: "https://dev-enterprise.company.com/apps",
    organizationID: "dev-org-id"
)
```

#### Production Environment

For production, use secure configurations:

```swift
let prodConfig = EnterpriseDeploymentConfiguration(
    mdmServerURL: "https://mdm.company.com",
    appStoreURL: "https://enterprise.company.com/apps",
    organizationID: "prod-org-id"
)
```

### 3. Security Configuration

#### Certificate Management

1. **Signing Certificate**: Ensure your signing certificate is valid and accessible
2. **Provisioning Profile**: Verify your provisioning profile includes the necessary entitlements
3. **MDM Certificate**: Configure MDM server certificates for secure communication

#### Network Security

1. **HTTPS**: All server URLs must use HTTPS
2. **Certificate Pinning**: Implement certificate pinning for additional security
3. **Firewall**: Configure firewall rules to allow MDM communication

## CLI Installation

### 1. Install CLI Tools

The framework includes command-line tools for automation:

```bash
# Clone the repository
git clone https://github.com/muhittincamdali/iOS-Enterprise-Deployment-Framework.git
cd iOS-Enterprise-Deployment-Framework

# Build CLI tools
swift build -c release --product EnterpriseDeploymentCLI

# Install CLI (optional)
sudo cp .build/release/EnterpriseDeploymentCLI /usr/local/bin/
```

### 2. Verify CLI Installation

```bash
enterprise-deployment --help
```

### 3. CLI Usage Examples

```bash
# Deploy an app
enterprise-deployment deploy --app-path /path/to/app.ipa --mdm-server https://mdm.company.com --org-id company-org

# Enroll a device
enterprise-deployment enroll --device-id device-001 --token enrollment-token --mdm-server https://mdm.company.com --org-id company-org

# Monitor deployment
enterprise-deployment monitor --deployment-id deployment-123

# Generate report
enterprise-deployment report --type deployment --period daily --output report.pdf
```

## Verification

### 1. Test Installation

Create a simple test to verify the installation:

```swift
import XCTest
import EnterpriseDeploymentCore

class InstallationTest: XCTestCase {
    func testFrameworkInstallation() {
        // Test basic configuration
        let config = EnterpriseDeploymentConfiguration(
            mdmServerURL: "https://test.com",
            appStoreURL: "https://test.com/apps",
            organizationID: "test-org"
        )
        
        XCTAssertNoThrow(try EnterpriseDeployment(configuration: config))
    }
}
```

### 2. Run Tests

```bash
# Run all tests
swift test

# Run specific test
swift test --filter InstallationTest
```

### 3. Check Dependencies

Verify all dependencies are properly installed:

```swift
import Crypto
import Logging
import NIO
import NIOSSL
import ArgumentParser

// If these imports work, dependencies are installed correctly
```

## Troubleshooting

### Common Issues

#### 1. Build Errors

**Problem**: Swift Package Manager build fails
**Solution**: 
- Update Xcode to latest version
- Clear derived data: `Xcode → Product → Clean Build Folder`
- Reset package cache: `File → Packages → Reset Package Caches`

#### 2. Import Errors

**Problem**: Cannot import framework modules
**Solution**:
- Ensure modules are added to target
- Check framework linking in target settings
- Verify Swift Package Manager integration

#### 3. Configuration Errors

**Problem**: Framework initialization fails
**Solution**:
- Verify all required configuration parameters
- Check network connectivity to MDM server
- Validate certificates and provisioning profiles

#### 4. Runtime Errors

**Problem**: Framework crashes at runtime
**Solution**:
- Check iOS deployment target compatibility
- Verify entitlements are properly configured
- Review console logs for specific error messages

### Getting Help

If you encounter issues:

1. **Check Documentation**: Review the comprehensive documentation
2. **Search Issues**: Look for similar issues in the GitHub repository
3. **Create Issue**: Report bugs with detailed information
4. **Community Support**: Ask questions in discussions

## Next Steps

After successful installation:

1. **Read Documentation**: Review the comprehensive documentation
2. **Try Examples**: Run the provided examples
3. **Configure Security**: Set up proper security configurations
4. **Test Integration**: Test with your MDM system
5. **Deploy to Production**: Follow production deployment guidelines

## Support

For additional support:

- **Documentation**: [Framework Documentation](Documentation/)
- **Examples**: [Usage Examples](Examples/)
- **Issues**: [GitHub Issues](https://github.com/muhittincamdali/iOS-Enterprise-Deployment-Framework/issues)
- **Discussions**: [GitHub Discussions](https://github.com/muhittincamdali/iOS-Enterprise-Deployment-Framework/discussions) 