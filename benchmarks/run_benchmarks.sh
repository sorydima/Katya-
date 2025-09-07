#!/bin/bash

echo "Running Katya performance benchmarks..."

# Startup time benchmark
echo "Measuring startup time..."
flutter run --profile --trace-startup

# Memory usage benchmark
echo "Measuring memory usage..."
flutter run --profile &

# Wait for app to start
sleep 10

# Frame rate benchmark
echo "Measuring frame rate..."
flutter run --profile --trace-skia

echo "Benchmarks completed."
