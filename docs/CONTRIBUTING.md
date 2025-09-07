# Contributing to Katya

Thank you for your interest in contributing to Katya! This document provides guidelines and information for contributors.

## Table of Contents

- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Finding Issues to Work On](#finding-issues-to-work-on)
- [Making Changes](#making-changes)
- [Submitting Changes](#submitting-changes)
- [Code Review Process](#code-review-process)
- [Testing](#testing)
- [Documentation](#documentation)
- [Community Guidelines](#community-guidelines)
- [Getting Help](#getting-help)

## Getting Started

### Prerequisites

Before you begin, ensure you have:

- Flutter SDK (3.10.0 or later)
- Dart SDK (3.0.0 or later)
- Git
- A code editor (VS Code recommended with Flutter extensions)
- Basic knowledge of Flutter/Dart development

### Fork and Clone

1. Fork the repository on GitHub
2. Clone your fork locally:
   ```bash
   git clone https://github.com/your-username/katya.git
   cd katya
   ```
3. Add the upstream remote:
   ```bash
   git remote add upstream https://github.com/katya-project/katya.git
   ```

## Development Setup

### Environment Setup

1. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

2. Generate code (if needed):
   ```bash
   flutter pub run build_runner build
   ```

3. Verify setup:
   ```bash
   flutter doctor
   ```

### Running the App

```bash
# Run on connected device/emulator
flutter run

# Run on specific platform
flutter run -d android
flutter run -d ios
flutter run -d web
```

### Development Workflow

1. Create a feature branch:
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. Make your changes following the coding standards

3. Test your changes:
   ```bash
   flutter test
   flutter analyze
   ```

4. Commit your changes:
   ```bash
   git add .
   git commit -m "feat: add your feature description"
   ```

5. Push to your fork:
   ```bash
   git push origin feature/your-feature-name
   ```

6. Create a Pull Request

## Finding Issues to Work On

### Good First Issues

Look for issues labeled `good first issue` or `beginner-friendly`:

- [Good First Issues](https://github.com/katya-project/katya/labels/good%20first%20issue)
- [Beginner Friendly](https://github.com/katya-project/katya/labels/beginner-friendly)

### Issue Labels

- `bug`: Bug reports
- `enhancement`: Feature requests
- `documentation`: Documentation improvements
- `help wanted`: Issues that need community help
- `question`: Questions and discussions

### Areas for Contribution

- **Code**: New features, bug fixes, performance improvements
- **Tests**: Unit tests, widget tests, integration tests
- **Documentation**: Guides, tutorials, API documentation
- **UI/UX**: Design improvements, accessibility enhancements
- **Internationalization**: Translations and localization
- **Tools**: Development tools, scripts, CI/CD improvements

## Making Changes

### Coding Standards

Follow these coding standards:

1. **Dart Style Guide**: Follow the [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
2. **Flutter Best Practices**: Follow [Flutter best practices](https://flutter.dev/docs/development/best-practices)
3. **Code Formatting**: Use `flutter format` to format code
4. **Linting**: Ensure code passes `flutter analyze`

### Commit Messages

Use conventional commit format:

```
type(scope): description

[optional body]

[optional footer]
```

Types:
- `feat`: New features
- `fix`: Bug fixes
- `docs`: Documentation changes
- `style`: Code style changes
- `refactor`: Code refactoring
- `test`: Adding tests
- `chore`: Maintenance tasks

Examples:
```
feat: add dark mode support
fix: resolve crash on message send
docs: update installation guide
```

### Branch Naming

Use descriptive branch names:

```
feature/add-dark-mode
bugfix/crash-on-message-send
docs/update-installation-guide
```

## Submitting Changes

### Pull Request Process

1. **Ensure your branch is up to date**:
   ```bash
   git fetch upstream
   git rebase upstream/main
   ```

2. **Create a Pull Request**:
   - Go to your fork on GitHub
   - Click "New Pull Request"
   - Select your feature branch
   - Fill out the PR template

3. **PR Template**:
   ```markdown
   ## Description
   Brief description of the changes

   ## Type of Change
   - [ ] Bug fix
   - [ ] New feature
   - [ ] Breaking change
   - [ ] Documentation update

   ## Testing
   - [ ] Unit tests added/updated
   - [ ] Widget tests added/updated
   - [ ] Integration tests added/updated
   - [ ] Manual testing completed

   ## Screenshots (if applicable)
   Add screenshots of UI changes

   ## Checklist
   - [ ] Code follows style guidelines
   - [ ] Tests pass
   - [ ] Documentation updated
   - [ ] Self-review completed
   ```

### PR Requirements

Before submitting a PR, ensure:

- [ ] Code follows project coding standards
- [ ] All tests pass (`flutter test`)
- [ ] Code analysis passes (`flutter analyze`)
- [ ] Documentation is updated if needed
- [ ] Commit messages follow conventional format
- [ ] Branch is up to date with main
- [ ] No merge conflicts

## Code Review Process

### Review Guidelines

**For Contributors:**
- Be open to feedback and suggestions
- Explain your design decisions when requested
- Make requested changes promptly
- Ask questions if something is unclear

**For Reviewers:**
- Be constructive and respectful
- Explain reasoning for requested changes
- Focus on code quality, not personal preferences
- Acknowledge good work and improvements

### Review Checklist

- [ ] Code follows project conventions
- [ ] Tests are comprehensive and pass
- [ ] Documentation is updated
- [ ] No security vulnerabilities
- [ ] Performance considerations addressed
- [ ] Accessibility requirements met
- [ ] Breaking changes are documented

### Approval Process

1. **Automated Checks**: CI/CD pipelines must pass
2. **Code Review**: At least one maintainer review required
3. **Testing**: All tests must pass
4. **Approval**: Maintainers approve the PR
5. **Merge**: PR is merged by a maintainer

## Testing

### Test Requirements

- **Unit Tests**: Test individual functions and classes
- **Widget Tests**: Test UI components
- **Integration Tests**: Test feature interactions
- **Golden Tests**: Test UI consistency (when applicable)

### Running Tests

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/unit/auth_service_test.dart

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/
```

### Test Coverage

Aim for:
- 80%+ overall test coverage
- 90%+ coverage for critical business logic
- All new features must have corresponding tests

## Documentation

### Documentation Types

- **Code Comments**: Explain complex logic and algorithms
- **API Documentation**: Document public APIs with dartdoc
- **User Guides**: Update user-facing documentation
- **Architecture Docs**: Update technical documentation for major changes

### Documentation Standards

- Use clear, concise language
- Include code examples where helpful
- Keep documentation up to date with code changes
- Use consistent formatting and structure

## Community Guidelines

### Communication

- Be respectful and inclusive in all interactions
- Use welcoming and inclusive language
- Be patient with new contributors
- Focus on constructive feedback

### Getting Help

- **GitHub Issues**: For bugs and feature requests
- **GitHub Discussions**: For questions and general discussion
- **Matrix Chat**: For real-time community support
- **Documentation**: Check existing docs first

### Recognition

Contributors are recognized through:
- GitHub contributor statistics
- Release notes and changelogs
- Community shoutouts
- Contributor badges and roles

## Getting Help

### Resources

- [Development Guide](DEVELOPMENT.md): Setup and development practices
- [Testing Guide](TESTING.md): Testing strategies and practices
- [Architecture Guide](ARCHITECTURE.md): System design and patterns
- [Deployment Guide](DEPLOYMENT.md): Building and deploying Katya

### Community Support

- **GitHub Issues**: Report bugs and request features
- **GitHub Discussions**: Ask questions and discuss ideas
- **Matrix Room**: #katya:matrix.org for real-time chat
- **Discord**: Join our Discord server for community support

### Office Hours

We hold regular office hours for contributors:
- **Time**: Every Tuesday 2-3 PM UTC
- **Location**: Matrix room #katya-office-hours:matrix.org
- **Purpose**: Q&A, mentoring, and community discussion

## Recognition and Rewards

### Contributor Recognition

- **First-time Contributors**: Welcome message and swag
- **Regular Contributors**: Monthly recognition in community updates
- **Top Contributors**: Annual recognition and special perks
- **Maintainers**: Special recognition and project influence

### Contributor Perks

- Early access to new features
- Project-branded merchandise
- Conference sponsorship opportunities
- Invitations to contributor events

## Code of Conduct

All contributors must adhere to our [Code of Conduct](CODE_OF_CONDUCT.md). This includes:

- Treating all community members with respect
- Maintaining professional communication
- Resolving conflicts constructively
- Leading by example

Violations of the code of conduct will be handled according to the procedures outlined in the Code of Conduct document.

---

Thank you for contributing to Katya! Your contributions help make this project better for everyone in the community.

*For questions about this contributing guide, please open an issue or start a discussion on GitHub.*
