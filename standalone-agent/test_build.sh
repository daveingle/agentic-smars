#!/bin/bash

echo "🔧 Testing SMARS Standalone Agent Build"
echo "======================================="

# Build the project
echo "📦 Building project..."
cargo build --release

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    
    # Show binary info
    ls -la target/release/smars-standalone-agent
    
    echo ""
    echo "🚀 Ready to test! Example usage:"
    echo "  ./target/release/smars-standalone-agent --prompt \"Create a simple web app\""
    echo "  ./target/release/smars-standalone-agent --prompt \"Analyze data patterns\" --multi-agent"
    echo "  ./target/release/smars-standalone-agent --prompt \"Build a CLI tool\" --verbose"
    
else
    echo "❌ Build failed!"
    exit 1
fi