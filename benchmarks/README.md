# Performance Benchmarks

This directory contains performance benchmark scripts for the Katya application.

## Available Benchmarks

### 1. Startup Time Benchmark
Measures the time it takes for the app to start up.

```bash
flutter run --profile --trace-startup
```

### 2. Memory Usage Benchmark
Monitors memory usage during app operation.

```bash
flutter run --profile
# Use Flutter DevTools to analyze memory usage
```

### 3. Frame Rate Benchmark
Tests UI performance and frame rates.

```bash
flutter run --profile --trace-skia
```

## Running Benchmarks

### Automated Benchmark Script
```bash
./benchmarks/run_benchmarks.sh
```

### Manual Testing
1. Run the app in profile mode:
   ```bash
   flutter run --profile
   ```

2. Use Flutter DevTools to analyze performance:
   ```bash
   flutter pub global run devtools
   ```

3. Open the DevTools URL in your browser

## Benchmark Results

Results are stored in the `results/` directory with timestamps.

## CI Integration

Benchmarks are automatically run on:
- Pull requests to main/develop branches
- Weekly on the main branch

Results are compared against baseline performance metrics.
