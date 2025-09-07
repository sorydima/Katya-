# 🧪 Katya Testing Guide

## Overview

This document outlines the testing strategy and practices for the Katya project, ensuring code quality, reliability, and maintainability.

## Table of Contents

- [Testing Strategy](#testing-strategy)
- [Unit Testing](#unit-testing)
- [Widget Testing](#widget-testing)
- [Integration Testing](#integration-testing)
- [End-to-End Testing](#end-to-end-testing)
- [Performance Testing](#performance-testing)
- [Accessibility Testing](#accessibility-testing)
- [Test Organization](#test-organization)
- [Mocking and Fakes](#mocking-and-fakes)
- [Continuous Integration](#continuous-integration)
- [Test Coverage](#test-coverage)
- [Best Practices](#best-practices)
- [Debugging Tests](#debugging-tests)

## Testing Strategy

### Testing Pyramid

```
End-to-End Tests (Fewer)
    ↕️
Integration Tests
    ↕️
Widget Tests
    ↕️
Unit Tests (Many)
```

### Test Categories

1. **Unit Tests**: Test individual functions and classes in isolation
2. **Widget Tests**: Test Flutter widgets and UI components
3. **Integration Tests**: Test interactions between components
4. **End-to-End Tests**: Test complete user workflows
5. **Performance Tests**: Test app performance and responsiveness
6. **Accessibility Tests**: Test screen reader and keyboard navigation

## Unit Testing

### Setting Up Unit Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:katya/services/auth_service.dart';

void main() {
  group('AuthService', () {
    late AuthService authService;

    setUp(() {
      authService = AuthService();
    });

    test('should authenticate user with valid credentials', () async {
      // Arrange
      const username = 'test@example.com';
      const password = 'password123';

      // Act
      final result = await authService.authenticate(username, password);

      // Assert
      expect(result, isTrue);
    });

    test('should throw exception for invalid credentials', () async {
      // Arrange
      const username = 'invalid@example.com';
      const password = 'wrongpassword';

      // Act & Assert
      expect(
        () => authService.authenticate(username, password),
        throwsA(isA<AuthenticationException>()),
      );
    });
  });
}
```

### Testing Async Code

```dart
test('should handle async operations correctly', () async {
  // Test async operations
  final future = authService.authenticateAsync('user', 'pass');

  expect(future, completes);
  expect(await future, isTrue);
});
```

## Widget Testing

### Basic Widget Test

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:katya/widgets/login_form.dart';

void main() {
  testWidgets('LoginForm should display email and password fields',
      (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      MaterialApp(
        home: LoginForm(),
      ),
    );

    // Verify UI elements
    expect(find.byType(TextFormField), findsNWidgets(2));
    expect(find.text('Email'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsOneWidget);
  });

  testWidgets('LoginForm should validate email input',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: LoginForm(),
      ),
    );

    // Enter invalid email
    await tester.enterText(find.byType(TextFormField).first, 'invalid-email');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();

    // Verify validation error
    expect(find.text('Please enter a valid email'), findsOneWidget);
  });
}
```

### Testing Widget Interactions

```dart
testWidgets('should call onLogin when form is submitted',
    (WidgetTester tester) async {
  bool loginCalled = false;

  await tester.pumpWidget(
    MaterialApp(
      home: LoginForm(
        onLogin: () => loginCalled = true,
      ),
    ),
  );

  // Fill form
  await tester.enterText(find.byType(TextFormField).first, 'test@example.com');
  await tester.enterText(find.byType(TextFormField).last, 'password123');

  // Submit form
  await tester.tap(find.byType(ElevatedButton));
  await tester.pump();

  // Verify callback was called
  expect(loginCalled, isTrue);
});
```

## Integration Testing

### Setting Up Integration Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:katya/main.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('end-to-end test', (WidgetTester tester) async {
    // Launch the app
    await tester.pumpWidget(MyApp());

    // Navigate through the app
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    // Perform actions
    await tester.enterText(find.byType(TextFormField).first, 'user@example.com');
    await tester.enterText(find.byType(TextFormField).last, 'password');
    await tester.tap(find.text('Sign In'));
    await tester.pumpAndSettle();

    // Verify results
    expect(find.text('Welcome'), findsOneWidget);
  });
}
```

## End-to-End Testing

### E2E Test Structure

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:katya/main.dart';

void main() {
  testWidgets('complete user registration flow', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Navigate to registration
    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();

    // Fill registration form
    await tester.enterText(find.byKey(Key('username')), 'testuser');
    await tester.enterText(find.byKey(Key('email')), 'test@example.com');
    await tester.enterText(find.byKey(Key('password')), 'password123');
    await tester.enterText(find.byKey(Key('confirmPassword')), 'password123');

    // Submit form
    await tester.tap(find.text('Register'));
    await tester.pumpAndSettle();

    // Verify success
    expect(find.text('Registration successful'), findsOneWidget);
  });
}
```

## Performance Testing

### Widget Performance Testing

```dart
testWidgets('widget should build within performance budget',
    (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ExpensiveWidget(),
    ),
  );

  // Measure build time
  final stopwatch = Stopwatch()..start();
  await tester.pump();
  stopwatch.stop();

  // Assert performance budget
  expect(stopwatch.elapsedMilliseconds, lessThan(16)); // 60 FPS
});
```

### Memory Leak Testing

```dart
testWidgets('should not have memory leaks', (WidgetTester tester) async {
  // Test for memory leaks by creating and disposing widgets
  await tester.pumpWidget(MyWidget());
  await tester.pumpWidget(Container()); // Dispose

  // Force garbage collection (in debug mode)
  // Verify no memory leaks
});
```

## Accessibility Testing

### Screen Reader Testing

```dart
testWidgets('should be accessible to screen readers',
    (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Semantics(
        label: 'Login button',
        hint: 'Tap to log in to your account',
        child: ElevatedButton(
          onPressed: () {},
          child: Text('Login'),
        ),
      ),
    ),
  );

  final semantics = tester.getSemantics(find.byType(ElevatedButton));

  expect(semantics.label, 'Login button');
  expect(semantics.hint, 'Tap to log in to your account');
});
```

### Keyboard Navigation Testing

```dart
testWidgets('should support keyboard navigation',
    (WidgetTester tester) async {
  await tester.pumpWidget(MyApp());

  // Test Tab navigation
  await tester.sendKeyEvent(LogicalKeyboardKey.tab);
  expect(find.focused, findsOneWidget);

  // Test Enter key
  await tester.sendKeyEvent(LogicalKeyboardKey.enter);
  await tester.pump();
  // Verify action was performed
});
```

## Test Organization

### Directory Structure

```
test/
├── unit/
│   ├── services/
│   ├── models/
│   └── utils/
├── widget/
│   ├── components/
│   └── screens/
├── integration/
│   ├── auth_flow_test.dart
│   └── messaging_flow_test.dart
└── e2e/
    ├── user_registration_test.dart
    └── messaging_workflow_test.dart
```

### Test Naming Conventions

- Use descriptive names: `should_return_user_when_authenticated`
- Group related tests in `group()` blocks
- Use `testWidgets` for widget tests
- Use `test` for unit tests

## Mocking and Fakes

### Using Mockito for Mocks

```dart
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

// Generate mocks
@GenerateMocks([AuthService, ApiClient])
void main() {}

class MockAuthService extends Mock implements AuthService {}

test('should call API with correct parameters', () {
  final mockApi = MockApiClient();
  final service = AuthService(mockApi);

  when(mockApi.authenticate(any, any))
      .thenAnswer((_) async => AuthResponse.success());

  service.authenticate('user', 'pass');

  verify(mockApi.authenticate('user', 'pass')).called(1);
});
```

### Fake Implementations

```dart
class FakeAuthService implements AuthService {
  @override
  Future<bool> authenticate(String username, String password) async {
    if (username == 'test' && password == 'password') {
      return true;
    }
    throw AuthenticationException('Invalid credentials');
  }
}
```

## Continuous Integration

### GitHub Actions Test Workflow

```yaml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'

      - name: Install dependencies
        run: flutter pub get

      - name: Run tests
        run: flutter test --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: coverage/lcov.info
```

## Test Coverage

### Generating Coverage Reports

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### Coverage Goals

- Aim for 80%+ overall coverage
- Critical business logic: 90%+ coverage
- UI components: 70%+ coverage
- Integration tests: Cover all major user flows

## Best Practices

### Writing Good Tests

1. **Test Behavior, Not Implementation**
   - Focus on what the code does, not how it does it
   - Tests should be resilient to refactoring

2. **Keep Tests Fast and Isolated**
   - Each test should run quickly
   - Tests should not depend on each other
   - Use proper setup and teardown

3. **Use Descriptive Names**
   - Test names should explain what they're testing
   - Use BDD-style naming when appropriate

4. **Test Edge Cases**
   - Test null values, empty collections, boundary conditions
   - Test error conditions and exception handling

5. **Maintain Test Code Quality**
   - Apply same code quality standards to tests
   - Refactor test code when it becomes complex

### Test-Driven Development (TDD)

1. Write a failing test
2. Write minimal code to make the test pass
3. Refactor the code while keeping tests passing

### Behavior-Driven Development (BDD)

```dart
test('User authentication', () {
  given('a user with valid credentials')
    .when('they attempt to log in')
    .then('they should be authenticated successfully');
});
```

## Debugging Tests

### Common Debugging Techniques

1. **Print Statements**
```dart
test('debug test', () {
  final result = someFunction();
  print('Result: $result'); // Debug output
  expect(result, expectedValue);
});
```

2. **Using Debugger**
```dart
test('debug with breakpoint', () {
  debugger(); // Add breakpoint
  final result = someFunction();
  expect(result, expectedValue);
});
```

3. **Test Isolation**
```dart
test('isolated test', () {
  // Ensure test doesn't depend on external state
  TestWidgetsFlutterBinding.ensureInitialized();
  // ... test code
});
```

### Troubleshooting Failing Tests

1. **Check Test Setup**
   - Ensure proper widget tree setup
   - Verify mock configurations
   - Check async operation handling

2. **Widget Tree Issues**
```dart
testWidgets('debug widget tree', (tester) async {
  await tester.pumpWidget(MyWidget());

  // Print widget tree for debugging
  debugDumpApp();

  expect(find.text('Expected Text'), findsOneWidget);
});
```

3. **Async Test Issues**
```dart
test('async test with timeout', () async {
  final result = await someAsyncFunction().timeout(
    Duration(seconds: 5),
    onTimeout: () => fail('Test timed out'),
  );
  expect(result, expectedValue);
});
```

## Test Maintenance

### Updating Tests After Refactoring

1. **Identify Affected Tests**
   - Run tests to see which ones fail
   - Update test expectations to match new behavior

2. **Refactor Test Code**
   - Remove duplicate test code
   - Extract common test utilities
   - Improve test readability

### Test Data Management

```dart
class TestData {
  static const validUser = User(
    id: 'test-id',
    email: 'test@example.com',
    name: 'Test User',
  );

  static const invalidUser = User(
    id: 'invalid-id',
    email: 'invalid-email',
    name: '',
  );
}
```

## Integration with Development Workflow

### Pre-commit Hooks

```bash
#!/bin/bash
# pre-commit hook to run tests

echo "Running tests..."
flutter test

if [ $? -ne 0 ]; then
  echo "Tests failed. Please fix before committing."
  exit 1
fi

echo "All tests passed!"
```

### IDE Integration

- Configure test runners in VS Code/Android Studio
- Set up test debugging configurations
- Enable test coverage visualization

## Conclusion

A comprehensive testing strategy is essential for maintaining code quality and preventing regressions in the Katya project. By following the practices outlined in this guide, developers can ensure that:

- Code changes are validated through automated tests
- User-facing features work as expected
- Performance and accessibility requirements are met
- The codebase remains maintainable and reliable

Remember to run tests frequently during development and always before committing changes. The goal is not just to have tests, but to have meaningful tests that provide confidence in the codebase.

For more information about specific testing scenarios or to contribute new test cases, refer to the [CONTRIBUTING.md](CONTRIBUTING.md) file or join our community discussions.
