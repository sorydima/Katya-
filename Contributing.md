# Contributing to Katya

Thank you for your interest in contributing to Katya! We welcome contributions from the community and are excited to have you on board.

## How to Contribute

There are several ways you can contribute to the Katya project:

### 🐛 Reporting Bugs
- Use the [bug report template](.github/ISSUE_TEMPLATE/bug_report.md) to report any issues you encounter
- Provide detailed steps to reproduce the bug
- Include information about your environment (OS, device, Katya version)

### 🚀 Suggesting Features
- Use the [feature request template](.github/ISSUE_TEMPLATE/feature_request.md) to suggest new features
- Explain the problem you're trying to solve
- Describe your proposed solution

### 📝 Improving Documentation
- Help us improve our documentation, tutorials, and examples
- Fix typos, clarify instructions, or add missing information

### 💻 Writing Code
- Fix bugs or implement new features
- Follow our coding standards and guidelines
- Write tests for your changes

## Development Setup

### Prerequisites
- Flutter SDK (version specified in pubspec.yaml)
- Dart SDK
- Platform-specific dependencies (Xcode for iOS, Android Studio for Android, etc.)

### Getting Started
1. Fork the repository
2. Clone your fork: `git clone https://github.com/your-username/Katya-.git`
3. Navigate to the project directory: `cd Katya-`
4. Install dependencies: `flutter pub get`
5. Run the app: `flutter run`

### Code Style
- Follow the Dart style guide: https://dart.dev/guides/language/effective-dart/style
- Use `dart format` to format your code before committing
- Follow existing patterns and conventions in the codebase
- Use descriptive variable and function names
- Add comments for complex logic
- Keep functions small and focused on a single responsibility
- Use const constructors where possible
- Prefer final over var when the type is clear
- Use trailing commas in multi-line collections for cleaner diffs
- Maximum line length: 120 characters
- Use snake_case for file names and directories
- Use PascalCase for class names
- Use camelCase for method and variable names
- Use UPPER_SNAKE_CASE for constants

### Testing
- Write unit tests for new functionality
- Ensure all tests pass before submitting a PR
- Run tests: `flutter test`
- Write integration tests for complex features
- Test on multiple platforms when possible

### Commit Message Conventions
We follow conventional commit format for clear and consistent commit messages:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
- `feat(auth): add biometric login support`
- `fix(ui): resolve crash on theme change`
- `docs(readme): update installation instructions`

### Branching Strategy
- `main`: Production-ready code
- `develop`: Latest development changes
- `feature/*`: New features
- `bugfix/*`: Bug fixes
- `hotfix/*`: Critical fixes for production
- `release/*`: Release preparation

Always create feature branches from `develop` and merge back via pull request.

## Pull Request Process

1. Create a new branch for your changes: `git checkout -b feature/your-feature-name`
2. Make your changes and commit them with descriptive messages
3. Push your branch: `git push origin feature/your-feature-name`
4. Open a pull request against the `main` branch
5. Ensure your PR description clearly explains the changes
6. Link any related issues in the PR description

### PR Requirements
- Code must be properly formatted (`dart format`)
- All tests must pass (`flutter test`)
- New features should include appropriate tests
- Documentation should be updated if necessary
- Follow the [pull request template](.github/PULL_REQUEST_TEMPLATE.md)
- Keep PRs focused on a single feature or fix
- Ensure CI checks pass

### Code Review Process
- All PRs require at least one approval from a maintainer
- Reviewers will check for:
  - Code quality and adherence to style guidelines
  - Test coverage
  - Performance implications
  - Security considerations
  - Documentation updates
- Address all review comments and make requested changes
- Once approved, a maintainer will merge the PR
- Use squash merge for feature branches to keep history clean

### PR Labels
- `bug`: Bug fixes
- `enhancement`: New features
- `documentation`: Documentation updates
- `refactor`: Code refactoring
- `breaking-change`: Breaking changes
- `work-in-progress`: Not ready for review

## Code of Conduct

Please note that this project is governed by our [Code of Conduct](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code.

## Getting Help

If you need help or have questions:
- Check the [documentation](docs/)
- Open an issue for discussion
- Join our community channels (if available)

## Recognition

All contributors will be recognized in our release notes and documentation. Significant contributions may lead to maintainer status.

Thank you for contributing to making Katya better! 🎉
