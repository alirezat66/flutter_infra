#!/bin/bash

echo "🧪 Running Flutter Infra Tests..."
echo "================================="

# Run all tests
flutter test

# Check if tests passed
if [ $? -eq 0 ]; then
    echo "✅ All tests passed!"
else
    echo "❌ Some tests failed!"
    exit 1
fi 