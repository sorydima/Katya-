# Development Guide

This guide covers the development practices, project structure, and workflows for contributing to Katya.

## Table of Contents
- [Project Structure](#project-structure)
- [Development Setup](#development-setup)
- [Coding Standards](#coding-standards)
- [Common Development Tasks](#common-development-tasks)
- [Testing](#testing)
- [Debugging](#debugging)
- [Performance Optimization](#performance-optimization)
- [Code Review Process](#code-review-process)
- [Dependency Management](#dependency-management)

## Project Structure

```
Katya/
├── lib/                    # Dart source code
│   ├── main.dart          # Application entry point
│   ├── core/              # Core functionality
│   ├── features/          # Feature modules
│   ├── services/          # Business logic services
│   ├── models/            # Data models
│   ├── repositories/      # Data access layer
│   ├── widgets/           # Reusable widgets
│   └── utils/             # Utility functions
├── test/                  # Test files
├── android/               # Android-specific code
├── ios/                   # iOS-specific code
├── web/                   # Web-specific code
├── linux/                 # Linux-specific code
├── windows/               # Windows-specific code
├── macos/                 # macOS-specific code
├── assets/                # Static assets
└── docs/                  # Documentation
```

## Development Setup

### Prerequisites
- Flutter SDK (version 3.0+)
- Dart SDK
- IDE: VS Code, Android Studio, or IntelliJ IDEA
- Flutter and Dart plugins for your IDE

### Initial Setup
1. Clone the repository
2. Run `flutter pub get` to install dependencies
3. Run `flutter doctor` to verify your setup
4. Configure your IDE with Flutter/Dart support

### IDE Configuration
Recommended VS Code settings (`.vscode/settings.json`):
```json
{
  "dart.lineLength": 80,
  "editor.formatOnSave": true,
  "editor.rulers": [80],
  "dart.debugExternalLibraries": true,
  "dart.debugSdkLibraries": false
}
```

## Coding Standards

### Dart Style Guide
Follow the [official Dart style guide](https://dart.dev/guides/language/effective-dart/style).

#### Key Points:
- Use 2 spaces for indentation
- Maximum line length: 80 characters
- Use `lowerCamelCase` for variables, functions, and methods
- Use `UpperCamelCase` for classes and types
- Use `lowercase_with_underscores` for library prefixes
- Prefer final and const where possible

#### Example:
```dart
// Good
class UserRepository {
  final UserService userService;
  
  Future<User> getUserById(int id) async {
    return await userService.fetchUser(id);
  }
}

// Bad
class user_repository {
  final UserService _userService;
  
  Future<User> get_user_by_id(int id) async {
    return await _userService.fetchUser(id);
  }
}
```

### Flutter Best Practices
- Use `const` widgets where possible for better performance
- Prefer composition over inheritance
- Use `Key` widgets appropriately for state management
- Avoid deep widget trees; extract into smaller widgets
- Use `Theme` for consistent styling

## Common Development Tasks

### Adding a New Feature
1. Create feature branch: `git checkout -b feature/your-feature-name`
2. Add your code in the appropriate directory structure
3. Write tests for your feature
4. Update documentation if needed
5. Run tests: `flutter test`
6. Format code: `flutter format .`
7. Create pull request

### Creating a New Widget
```dart
// lib/widgets/custom_button.dart
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isDisabled;

  const CustomButton({
    required this.text,
    required this.onPressed,
    this.isDisabled = false,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: isDisabled ? null : onPressed,
      child: Text(text),
    );
  }
}
```

### Adding a New Service
```dart
// lib/services/user_service.dart
import 'package:http/http.dart' as http;

class UserService {
  final String baseUrl;

  UserService({required this.baseUrl});

  Future<User> fetchUser(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/users/$id'));
    if (response.statusCode == 200) {
      return User.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load user');
    }
  }
}
```

## Testing

### Unit Tests
Place unit tests in `test/` directory with `_test.dart` suffix.

```dart
// test/services/user_service_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:katya/services/user_service.dart';

@GenerateMocks([http.Client])
void main() {
  group('UserService', () {
    test('fetches user successfully', () async {
      // Test implementation
    });
  });
}
```

### Widget Tests
```dart
// test/widgets/custom_button_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:katya/widgets/custom_button.dart';

void main() {
  testWidgets('CustomButton renders correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CustomButton(
          text: 'Test Button',
          onPressed: () {},
        ),
      ),
    );

    expect(find.text('Test Button'), findsOneWidget);
  });
}
```

### Running Tests
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/services/user_service_test.dart

# Run with coverage
flutter test --coverage
```

## Debugging

### Common Debugging Techniques
- Use `print()` statements for simple debugging
- Use breakpoints in your IDE
- Use `flutter analyze` to catch issues
- Use `flutter doctor -v` for detailed environment info

### DevTools
```bash
# Start DevTools
flutter pub global run devtools

# Or connect from IDE
# In VS Code: Ctrl+Shift+P -> "Flutter: Open DevTools"
```

### Common Issues
- **Hot reload not working**: Try hot restart (`flutter run --hot-restart`)
- **Build failures**: Run `flutter clean` and `flutter pub get`
- **Platform-specific issues**: Check `flutter doctor` output

## Performance Optimization

### Widget Optimization
- Use `const` constructors for static widgets
- Use `ListView.builder` for long lists
- Avoid unnecessary rebuilds with `const` and `final`
- Use `RepaintBoundary` for complex animations

### Memory Management
- Dispose controllers and streams in `dispose()` method
- Use `AutomaticKeepAliveClientMixin` for state preservation
- Monitor memory usage with DevTools

### Build Optimization
```bash
# Analyze app size
flutter build apk --analyze-size
flutter build ios --analyze-size

# Build with performance profiling
flutter run --profile
```

## Code Review Process

### Before Submitting PR
- [ ] Code follows Dart style guide
- [ ] All tests pass
- [ ] Documentation updated
- [ ] No breaking changes
- [ ] Performance considerations addressed
- [ ] Security considerations addressed

### Review Checklist
- [ ] Code is readable and maintainable
- [ ] Proper error handling implemented
- [ ] Tests cover new functionality
- [ ] No unnecessary dependencies added
- [ ] Follows existing patterns and conventions

## Dependency Management

### Adding Dependencies
Add to `pubspec.yaml`:
```yaml
dependencies:
  http: ^0.13.0
  provider: ^6.0.0

dev_dependencies:
  mockito: ^5.0.0
  build_runner: ^2.0.0
```

### Updating Dependencies
```bash
# Update all dependencies
flutter pub upgrade

# Update specific package
flutter pub upgrade package_name

# Check for outdated packages
flutter pub outdated
```

### Version Constraints
- Use caret syntax (`^1.2.3`) for compatible versions
- Use exact version (`1.2.3`) when necessary
- Avoid wildcard versions (`*`)

## Continuous Integration

The project uses GitHub Actions for CI. See [Workflow Templates](../.github/workflows/) for details.

### Local CI Checks
```bash
# Run all checks locally
flutter analyze
flutter test
flutter format --set-exit-if-changed .
flutter pub run dart_code_metrics:metrics analyze lib
```

## Getting Help

- Check existing [issues](https://github.com/sorydima/Katya-/issues)
- Ask in [discussions](https://github.com/sorydima/Katya-/discussions)
- Review [Flutter documentation](https://flutter.dev/docs)
- Consult [Dart language tour](https://dart.dev/guides/language/language-tour)

## Changelog

See [CHANGELOG.md](../CHANGELOG.md) for development-related changes and updates.