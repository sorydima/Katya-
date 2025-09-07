# Visual Regression Testing

This directory contains visual regression testing setup and configurations for the Katya application.

## Overview

Visual regression testing ensures that UI changes don't introduce unintended visual differences. It captures screenshots of UI components and compares them against baseline images to detect visual regressions.

## Architecture

### Components
```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Test Runner   │    │  Screenshot     │    │  Image Compare  │
│                 │    │  Capture        │    │  Engine         │
└─────────────────┘    └─────────────────┘    └─────────────────┘
         │                       │                       │
         └───────────────────────┼───────────────────────┘
                                 │
                    ┌─────────────────┐
                    │   Baseline      │
                    │   Images        │
                    └─────────────────┘
```

### Workflow
1. **Baseline Creation**: Capture screenshots of current UI state
2. **Test Execution**: Run tests that capture new screenshots
3. **Comparison**: Compare new screenshots with baselines
4. **Reporting**: Generate reports of visual differences
5. **Approval**: Review and approve changes or update baselines

## Setup

### Dependencies
```yaml
# pubspec.yaml
dev_dependencies:
  flutter_test:
    sdk: flutter
  integration_test:
    sdk: flutter
  flutter_driver:
    sdk: flutter
  visual_regression_test: ^1.0.0
```

### Configuration
```dart
// test_driver/integration_test.dart
import 'package:integration_test/integration_test_driver.dart';

Future<void> main() => integrationDriver();
```

## Test Structure

### Basic Visual Test
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:visual_regression_test/visual_regression_test.dart';

void main() {
  VisualRegressionTester tester;

  setUp(() async {
    tester = VisualRegressionTester();
    await tester.setUp();
  });

  tearDown(() async {
    await tester.tearDown();
  });

  testWidgets('Login screen visual test', (WidgetTester tester) async {
    await tester.pumpWidget(MyApp());

    // Navigate to login screen
    await tester.tap(find.byKey(Key('login_button')));
    await tester.pumpAndSettle();

    // Capture screenshot
    await tester.captureScreenshot('login_screen');

    // Compare with baseline
    final result = await tester.compareScreenshot('login_screen');
    expect(result.matches, isTrue);
  });
}
```

### Component-Level Testing
```dart
class ChatBubbleTest extends VisualRegressionTest {
  @override
  String get testName => 'chat_bubble';

  @override
  Widget buildTestWidget() {
    return MaterialApp(
      home: Scaffold(
        body: ChatBubble(
          message: 'Hello World',
          isMine: false,
          timestamp: DateTime.now(),
        ),
      ),
    );
  }

  @override
  Future<void> runTest(WidgetTester tester) async {
    await tester.pumpAndSettle();

    // Test different states
    await tester.captureScreenshot('chat_bubble_default');

    // Test with long message
    await tester.captureScreenshot('chat_bubble_long_message');

    // Test with emoji
    await tester.captureScreenshot('chat_bubble_with_emoji');
  }
}
```

## Advanced Features

### Responsive Testing
```dart
testWidgets('Responsive design test', (tester) async {
  // Test different screen sizes
  await tester.binding.setSurfaceSize(Size(375, 667)); // iPhone SE
  await tester.pumpWidget(MyApp());
  await tester.captureScreenshot('responsive_mobile');

  await tester.binding.setSurfaceSize(Size(768, 1024)); // iPad
  await tester.pumpWidget(MyApp());
  await tester.captureScreenshot('responsive_tablet');

  await tester.binding.setSurfaceSize(Size(1920, 1080)); // Desktop
  await tester.pumpWidget(MyApp());
  await tester.captureScreenshot('responsive_desktop');
});
```

### Theme Testing
```dart
testWidgets('Theme consistency test', (tester) async {
  // Test light theme
  await tester.pumpWidget(
    Theme(
      data: ThemeData.light(),
      child: MyApp(),
    ),
  );
  await tester.captureScreenshot('theme_light');

  // Test dark theme
  await tester.pumpWidget(
    Theme(
      data: ThemeData.dark(),
      child: MyApp(),
    ),
  );
  await tester.captureScreenshot('theme_dark');
});
```

### Animation Testing
```dart
testWidgets('Animation test', (tester) async {
  await tester.pumpWidget(MyApp());

  // Start animation
  await tester.tap(find.byKey(Key('animate_button')));
  await tester.pump();

  // Capture frames during animation
  for (int i = 0; i < 10; i++) {
    await tester.pump(Duration(milliseconds: 100));
    await tester.captureScreenshot('animation_frame_$i');
  }

  // Verify animation completes
  await tester.pumpAndSettle();
  await tester.captureScreenshot('animation_complete');
});
```

## CI/CD Integration

### GitHub Actions Workflow
```yaml
name: Visual Regression Tests
on:
  pull_request:
    branches: [ main, develop ]

jobs:
  visual-regression:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3

    - name: Setup Flutter
      uses: subosito/flutter-action@v2
      with:
        flutter-version: '3.10.0'

    - name: Install dependencies
      run: flutter pub get

    - name: Run visual regression tests
      run: flutter test integration_test/visual_regression_test.dart

    - name: Upload visual diff artifacts
      if: failure()
      uses: actions/upload-artifact@v3
      with:
        name: visual-regression-diffs
        path: test/visual-regression/diffs/
```

### Baseline Management
```bash
# Update baselines
flutter test integration_test/visual_regression_test.dart --update-baselines

# Compare against specific baseline
flutter test integration_test/visual_regression_test.dart --baseline=production
```

## Image Comparison Algorithms

### Pixel-by-Pixel Comparison
```dart
class PixelComparator implements ImageComparator {
  @override
  ComparisonResult compare(Image baseline, Image current) {
    if (baseline.width != current.width || baseline.height != current.height) {
      return ComparisonResult.differentSize();
    }

    int diffPixels = 0;
    for (int y = 0; y < baseline.height; y++) {
      for (int x = 0; x < baseline.width; x++) {
        if (baseline.getPixel(x, y) != current.getPixel(x, y)) {
          diffPixels++;
        }
      }
    }

    final diffPercentage = diffPixels / (baseline.width * baseline.height);
    return ComparisonResult(
      matches: diffPercentage < 0.01, // 1% tolerance
      differencePercentage: diffPercentage,
    );
  }
}
```

### Perceptual Hash Comparison
```dart
class PerceptualHashComparator implements ImageComparator {
  @override
  ComparisonResult compare(Image baseline, Image current) {
    final baselineHash = perceptualHash(baseline);
    final currentHash = perceptualHash(current);

    final distance = hammingDistance(baselineHash, currentHash);
    final similarity = 1.0 - (distance / 64.0); // 64-bit hash

    return ComparisonResult(
      matches: similarity > 0.95, // 95% similarity threshold
      differencePercentage: (1.0 - similarity) * 100,
    );
  }
}
```

## Reporting and Analysis

### HTML Report Generation
```dart
class VisualRegressionReporter {
  static Future<void> generateReport(List<TestResult> results) async {
    final report = StringBuffer();
    report.writeln('<!DOCTYPE html>');
    report.writeln('<html><head><title>Visual Regression Report</title></head><body>');

    for (final result in results) {
      report.writeln('<h2>${result.testName}</h2>');
      if (!result.passed) {
        report.writeln('<img src="${result.baselineImage}" alt="Baseline">');
        report.writeln('<img src="${result.currentImage}" alt="Current">');
        report.writeln('<img src="${result.diffImage}" alt="Difference">');
      }
    }

    report.writeln('</body></html>');
    await File('visual-regression-report.html').writeAsString(report.toString());
  }
}
```

### Slack Integration
```dart
class SlackReporter {
  static Future<void> reportFailures(List<TestResult> results) async {
    final failedTests = results.where((r) => !r.passed).toList();

    if (failedTests.isEmpty) return;

    final message = {
      'text': '🚨 Visual Regression Tests Failed',
      'blocks': [
        {
          'type': 'section',
          'text': {
            'type': 'mrkdwn',
            'text': '${failedTests.length} visual regression(s) detected'
          }
        }
      ]
    };

    await http.post(
      Uri.parse(slackWebhookUrl),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(message),
    );
  }
}
```

## Best Practices

### Test Organization
1. **Group Related Tests**: Organize tests by component or feature
2. **Use Descriptive Names**: Clear test names for easy identification
3. **Isolate Tests**: Each test should be independent
4. **Regular Maintenance**: Keep baselines up to date

### Image Management
1. **Version Control**: Store baselines in Git
2. **Compression**: Use appropriate image formats
3. **Naming Convention**: Consistent naming for screenshots
4. **Cleanup**: Remove outdated baselines regularly

### Performance Considerations
1. **Parallel Execution**: Run tests in parallel when possible
2. **Selective Testing**: Only test changed components
3. **Caching**: Cache baseline images
4. **Resource Management**: Clean up temporary files

## Troubleshooting

### Common Issues

#### Screenshot Inconsistencies
```dart
// Ensure consistent screenshot conditions
await tester.binding.setSurfaceSize(Size(375, 667));
await tester.pumpAndSettle();

// Wait for animations to complete
await tester.pump(Duration(seconds: 1));
```

#### Font Rendering Differences
```dart
// Use consistent font loading
await loadTestFonts();

// Ensure text is rendered before screenshot
await tester.pump();
```

#### Platform-Specific Differences
```dart
// Handle platform-specific rendering
if (Platform.isAndroid) {
  // Android-specific setup
} else if (Platform.isIOS) {
  // iOS-specific setup
}
```

## Integration with Other Tools

### Chromatic (Storybook Integration)
```javascript
// chromatic.config.json
{
  "projectToken": "your-project-token",
  "buildScriptName": "build:storybook",
  "storybookBaseDir": "storybook-static"
}
```

### Percy (Visual Testing Service)
```yaml
# .percy.yml
version: 2
snapshot:
  widths: [375, 768, 1024]
  min-height: 1024
  enable-javascript: true
```

### Applitools Eyes
```dart
// Integration with Applitools
final eyes = Eyes();
await eyes.open('Katya App', 'Login Screen');
await eyes.checkWindow('Login Page');
await eyes.close();
```

## Resources

- [Flutter Testing Documentation](https://flutter.dev/docs/testing)
- [Visual Regression Testing Guide](https://storybook.js.org/docs/react/workflows/visual-testing)
- [Image Comparison Algorithms](https://en.wikipedia.org/wiki/Image_comparison)
- [Chromatic Documentation](https://www.chromatic.com/docs/)

## Contact

- **Testing Team**: testing@katya.rechain.network
- **QA Team**: qa@katya.rechain.network
- **DevOps Team**: devops@katya.rechain.network

---

*This visual regression testing guide is regularly updated with new techniques and best practices.*
