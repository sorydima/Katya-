# Development Tools

This directory contains custom development tools and scripts to improve the development workflow for the Katya project.

## Available Tools

### Code Generation
- `generate_icons.dart` - Generate app icons from source images
- `generate_splash.dart` - Generate splash screens
- `generate_colors.dart` - Generate color schemes from design tokens

### Build Tools
- `build_all.dart` - Build for all platforms
- `clean_build.dart` - Clean and rebuild project
- `analyze_code.dart` - Run comprehensive code analysis

### Testing Tools
- `run_tests.dart` - Run all test suites
- `generate_coverage.dart` - Generate test coverage reports
- `performance_test.dart` - Run performance benchmarks

### Development Utilities
- `setup_dev.dart` - Setup development environment
- `update_deps.dart` - Update all dependencies
- `format_code.dart` - Format all code files

## Usage

### Running Tools

```bash
# Run a specific tool
dart tools/generate_icons.dart

# Or use the Flutter run command
flutter pub run tools/generate_icons.dart
```

### Adding New Tools

1. Create a new Dart file in the `tools/` directory
2. Add the tool to the `pubspec.yaml` under `scripts` or `dev_dependencies`
3. Update this README with documentation
4. Test the tool thoroughly

## Tool Categories

### 1. Asset Management
Tools for managing images, icons, fonts, and other assets.

### 2. Code Quality
Tools for linting, formatting, and analyzing code quality.

### 3. Build Automation
Tools for automating build processes across platforms.

### 4. Testing
Tools for running tests, generating reports, and analyzing coverage.

### 5. Deployment
Tools for preparing releases and deployment packages.

## Contributing

When adding new tools:

1. Follow the existing naming conventions
2. Include comprehensive error handling
3. Add detailed logging
4. Write unit tests for the tool
5. Update documentation

## Dependencies

Tools may require additional dependencies. Add them to `pubspec.yaml`:

```yaml
dev_dependencies:
  image: ^4.0.0
  archive: ^3.3.0
  path: ^1.8.0
```

## Examples

### Creating a Simple Tool

```dart
import 'dart:io';

void main(List<String> args) {
  print('Running custom tool...');

  // Tool logic here

  print('Tool completed successfully!');
}
```

### Tool with Arguments

```dart
import 'dart:io';

void main(List<String> args) {
  if (args.isEmpty) {
    print('Usage: dart tool.dart <command>');
    exit(1);
  }

  final command = args[0];

  switch (command) {
    case 'build':
      // Build logic
      break;
    case 'test':
      // Test logic
      break;
    default:
      print('Unknown command: $command');
      exit(1);
  }
}
```

## Best Practices

1. **Error Handling**: Always handle errors gracefully
2. **Logging**: Provide clear progress and error messages
3. **Documentation**: Document all tools and their usage
4. **Testing**: Test tools in CI/CD pipeline
5. **Performance**: Optimize for speed and memory usage
6. **Cross-platform**: Ensure tools work on all target platforms
