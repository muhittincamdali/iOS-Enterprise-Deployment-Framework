# Contributing to iOS Enterprise Deployment Framework

Thank you for your interest in contributing to the iOS Enterprise Deployment Framework!

## 🤝 How to Contribute

We welcome contributions from the community:

- **Bug Reports** - Help us identify and fix issues
- **Feature Requests** - Suggest new features and improvements
- **Code Contributions** - Submit pull requests with code changes
- **Documentation** - Improve documentation and examples
- **Testing** - Help test the framework and report issues

## 📋 Code of Conduct

This project is committed to providing a welcoming and inclusive environment. We expect all contributors to:

- Be respectful and considerate of others
- Use inclusive language and avoid discriminatory comments
- Focus on constructive feedback and discussions
- Respect different viewpoints and experiences

## 🚀 Getting Started

### Prerequisites

- **Xcode 15.0+** - Latest Xcode version
- **Swift 5.9+** - Latest Swift version
- **iOS 15.0+** - Minimum iOS deployment target
- **macOS 12.0+** - Minimum macOS deployment target

### Development Setup

1. **Fork the repository**
   ```bash
   git clone https://github.com/your-username/iOS-Enterprise-Deployment-Framework.git
   cd iOS-Enterprise-Deployment-Framework
   ```

2. **Install dependencies**
   ```bash
   swift package resolve
   ```

3. **Build the project**
   ```bash
   swift build
   ```

4. **Run tests**
   ```bash
   swift test
   ```

## 📝 Development Guidelines

### Code Style

We follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/).

#### Naming Conventions

- **Types**: Use `PascalCase` for types, protocols, and extensions
- **Functions**: Use `camelCase` for functions and methods
- **Variables**: Use `camelCase` for variables and constants
- **Constants**: Use `SCREAMING_SNAKE_CASE` for global constants

### Documentation

All public APIs must be documented:

```swift
/// Manages enterprise app deployment and distribution.
///
/// This class provides comprehensive enterprise deployment capabilities including
/// MDM integration, app distribution, and compliance monitoring.
public class EnterpriseDeployment {
    /// Deploys an app bundle to enterprise devices.
    ///
    /// - Parameters:
    ///   - app: The app bundle to deploy
    ///   - devices: Optional list of target devices
    /// - Throws: `DeploymentError` if deployment fails
    /// - Returns: Deployment result with status and metadata
    public func deploy(app: AppBundle, to devices: [Device]? = nil) async throws -> DeploymentResult {
        // Implementation
    }
}
```

### Testing

All code changes must include appropriate tests:

```swift
import XCTest
@testable import EnterpriseDeploymentCore

final class EnterpriseDeploymentTests: XCTestCase {
    var deployment: EnterpriseDeployment!
    var mockConfiguration: Configuration!
    
    override func setUp() {
        super.setUp()
        mockConfiguration = Configuration()
        deployment = EnterpriseDeployment(configuration: mockConfiguration)
    }
    
    func testDeploymentSuccess() async throws {
        // Given
        let appBundle = AppBundle.mock()
        
        // When
        let result = try await deployment.deploy(app: appBundle)
        
        // Then
        XCTAssertEqual(result.status, .success)
        XCTAssertNotNil(result.metadata)
    }
}
```

## 🔄 Pull Request Process

### Before Submitting

1. **Ensure tests pass**
   ```bash
   swift test
   ```

2. **Update documentation**
   - Update README.md if needed
   - Add API documentation for new features
   - Update examples if applicable

3. **Create a descriptive title**
   - Use present tense: "Add feature" not "Added feature"
   - Be specific and concise

### Pull Request Template

```markdown
## Description

Brief description of the changes and why they are needed.

## Type of Change

- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing

- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Checklist

- [ ] Code follows the style guidelines
- [ ] Self-review of code completed
- [ ] Code is documented
- [ ] Tests are added/updated
- [ ] Documentation is updated
```

## 🐛 Bug Reports

### Bug Report Template

```markdown
## Bug Description

Clear and concise description of the bug.

## Steps to Reproduce

1. Go to '...'
2. Click on '...'
3. Scroll down to '...'
4. See error

## Expected Behavior

What you expected to happen.

## Actual Behavior

What actually happened.

## Environment

- iOS Version: [e.g., 15.0]
- Framework Version: [e.g., 1.5.0]
- Device: [e.g., iPhone 14 Pro]
- Xcode Version: [e.g., 15.0]
```

## 💡 Feature Requests

### Feature Request Template

```markdown
## Feature Description

Clear and concise description of the feature.

## Problem Statement

What problem does this feature solve?

## Proposed Solution

How should this feature work?

## Additional Context

Any additional context or examples.
```

## 🏷️ Release Process

### Versioning

We follow [Semantic Versioning](https://semver.org/):

- **MAJOR** - Breaking changes
- **MINOR** - New features, backward compatible
- **PATCH** - Bug fixes, backward compatible

### Release Checklist

- [ ] All tests pass
- [ ] Documentation is updated
- [ ] CHANGELOG.md is updated
- [ ] Version is bumped
- [ ] Release notes are prepared

## 🤝 Community

### Getting Help

- **GitHub Issues** - For bugs and feature requests
- **GitHub Discussions** - For questions and general discussion
- **Documentation** - Check the docs first
- **Examples** - Look at example code

## 📄 License

By contributing to this project, you agree that your contributions will be licensed under the MIT License.

---

Thank you for contributing to the iOS Enterprise Deployment Framework! 🚀 