
# Contributing to Katya

Thank you for considering contributing to Katya! We welcome all kinds of contributions, including code, documentation, bug reports, and feature requests.

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [How to Contribute](#how-to-contribute)
3. [Setting Up the Development Environment](#setting-up-the-development-environment)
4. [Reporting Issues](#reporting-issues)
5. [Submitting Pull Requests](#submitting-pull-requests)
6. [Style Guidelines](#style-guidelines)

## Code of Conduct

By participating in this project, you agree to abide by our [Code of Conduct](.github/CODE_OF_CONDUCT.md). Please take a moment to review it.

## How to Contribute

### Types of Contributions

We welcome contributions in many forms, including:

- **Bug Fixes:** Help us by fixing bugs.
- **New Features:** Implement new features or improve existing ones.
- **Documentation:** Improve or add to the documentation in the `/docs_for_landing` folder.
- **Tests:** Write unit tests in the `/test` folder to ensure the stability of the app.

Feel free to check out the [issues page](https://github.com/sorydima/Katya-/issues) for open tickets.

## Setting Up the Development Environment

### Prerequisites

Ensure you have the following installed:

- [Flutter](https://flutter.dev/docs/get-started/install) (for multi-platform development)
- [Dart](https://dart.dev/get-dart) (primary language for the app)
- [Android Studio](https://developer.android.com/studio) or [Xcode](https://developer.apple.com/xcode/) for platform-specific testing

### Installation

1. Clone the repository:

```bash
git clone https://github.com/sorydima/Katya-.git
cd Katya-
```

2. Install dependencies:

```bash
flutter pub get
```

3. Run the app on your desired platform:

```bash
flutter run
```

## Reporting Issues

If you encounter any issues or bugs, please report them through the [GitHub Issues page](https://github.com/sorydima/Katya-/issues).

When reporting an issue, please provide the following:

- A detailed description of the issue.
- Steps to reproduce the issue.
- The expected behavior.
- Screenshots or logs, if applicable.

## Submitting Pull Requests

1. **Fork** the repository and create your branch:

```bash
git checkout -b feature/your-feature-name
```

2. **Commit** your changes with clear messages:

```bash
git commit -m "Add description of changes"
```

3. **Push** to your forked repository:

```bash
git push origin feature/your-feature-name
```

4. Open a pull request against the `main` branch in the original repository.

### Guidelines for Pull Requests

- Ensure your code is clean and follows the [Dart style guidelines](https://dart.dev/guides/language/effective-dart).
- Write unit tests where applicable.
- Include relevant documentation updates in `/docs_for_landing`.

## Style Guidelines

We follow the standard Dart and Flutter best practices. Please refer to:

- [Dart Style Guide](https://dart.dev/guides/language/effective-dart/style)
- [Flutter Best Practices](https://flutter.dev/docs/cookbook)

All code should be properly formatted. You can run the formatter using:

```bash
flutter format .
```

Thank you for contributing to Katya!
