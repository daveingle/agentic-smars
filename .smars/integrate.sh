#!/bin/bash

# Integrate SMARS with repository workflow

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

echo "🔗 Integrating SMARS with repository workflow"

# Add SMARS to .gitignore if it doesn't exist
if [ -f "$REPO_ROOT/.gitignore" ]; then
    if ! grep -q "^\.smars/traces" "$REPO_ROOT/.gitignore"; then
        echo "" >> "$REPO_ROOT/.gitignore"
        echo "# SMARS substrate traces (logs are local-only)" >> "$REPO_ROOT/.gitignore"
        echo ".smars/traces/" >> "$REPO_ROOT/.gitignore"
    fi
else
    echo ".smars/traces/" > "$REPO_ROOT/.gitignore"
fi

# Add convenient alias to shell profile
ALIAS_LINE="alias smars='$REPO_ROOT/.smars/smars-cli.py'"

for profile in ~/.bashrc ~/.zshrc ~/.profile; do
    if [ -f "$profile" ]; then
        if ! grep -q "$ALIAS_LINE" "$profile"; then
            echo "" >> "$profile"
            echo "# SMARS substrate alias" >> "$profile"
            echo "$ALIAS_LINE" >> "$profile"
            echo "Added SMARS alias to $profile"
        fi
    fi
done

echo "✅ Repository integration complete"
echo ""
echo "Next steps:"
echo "  1. Restart your shell or run: source ~/.bashrc"
echo "  2. Check status: smars status"
echo "  3. Create your first plan: smars init my-feature"
echo "  4. Execute plan: smars exec my-feature"
