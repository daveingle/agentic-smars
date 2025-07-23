#!/bin/bash

echo "🔧 Building SMARS Plan Library for Standalone Agent"
echo "=================================================="

# Build the plan library binary
echo "📦 Building plan library extractor..."
cargo build --bin build_plan_library --release

if [ $? -eq 0 ]; then
    echo "✅ Build successful!"
    
    # Run the plan library builder
    echo "🔍 Extracting SMARS plans and patterns..."
    ./target/release/build_plan_library
    
    if [ $? -eq 0 ]; then
        echo "✅ Plan library extraction complete!"
        
        # Show library stats
        if [ -f "plan_library/plan_library.json" ]; then
            echo ""
            echo "📊 Library Statistics:"
            echo "  📁 Library file: $(du -h plan_library/plan_library.json | cut -f1)"
            echo "  📋 Total plans: $(cat plan_library/plan_library.json | jq '.metadata.total_plans')"
            echo "  🎨 Total patterns: $(cat plan_library/plan_library.json | jq '.metadata.total_patterns')"
            echo "  📜 Total contracts: $(cat plan_library/plan_library.json | jq '.metadata.total_contracts')"
            echo "  🔧 Total maplets: $(cat plan_library/plan_library.json | jq '.metadata.total_maplets')"
            echo "  📦 Total kinds: $(cat plan_library/plan_library.json | jq '.metadata.total_kinds')"
            echo ""
            echo "🎯 Domains available:"
            cat plan_library/plan_library.json | jq -r '.metadata.domains[]' | sed 's/^/  • /'
            echo ""
            echo "✅ Plan library ready for agent use!"
        else
            echo "❌ Plan library file not found!"
            exit 1
        fi
    else
        echo "❌ Plan library extraction failed!"
        exit 1
    fi
else
    echo "❌ Build failed!"
    exit 1
fi