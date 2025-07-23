#!/bin/bash

# SMARS Repository Substrate Initialization
# This script sets up SMARS planning substrate in any repository

set -e

REPO_ROOT=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
SMARS_DIR="$REPO_ROOT/.smars"

echo "🚀 Initializing SMARS Planning Substrate"
echo "Repository: $REPO_ROOT"

# Create SMARS directory structure
mkdir -p "$SMARS_DIR"/{specs,plans,agents,templates,traces,config}

# Create basic configuration
cat > "$SMARS_DIR/config/smars.toml" << 'EOF'
[smars]
version = "0.1.0"
substrate_mode = true

[execution]
deterministic = true
feedback_enforcement = true
reality_grounding = true
confidence_bounds = [0.1, 0.95]

[validation]
contract_validation = true
artifact_validation = true
reality_validation = true

[agents]
self_auditing = true
reality_simulation = true
temporal_reasoning = true

[templates]
auto_scaffold = true
plan_templates = ["feature", "bugfix", "refactor", "deployment"]
EOF

# Create starter plan template
cat > "$SMARS_DIR/templates/feature-plan.smars.md" << 'EOF'
# Feature Development Plan Template

@role(developer)

(kind FeatureRequirement {
  requirement_id: STRING,
  description: STRING,
  acceptance_criteria: [STRING],
  priority: INT
})

(kind FeatureImplementation {
  implementation_id: STRING,
  components: [STRING],
  tests: [STRING],
  documentation: [STRING]
})

(datum feature_template ⟦"feature_${timestamp}"⟧)

(maplet analyze_requirements ∷ FeatureRequirement → AnalysisResult)
(maplet design_implementation ∷ AnalysisResult → ImplementationPlan)
(maplet execute_implementation ∷ ImplementationPlan → FeatureImplementation)
(maplet validate_feature ∷ FeatureImplementation → ValidationResult)

(contract feature_development_contract
  requires: well_defined_requirements(requirement_completeness > 0.8)
  ensures: implementation_meets_requirements(acceptance_criteria_met)
  ensures: tests_provide_adequate_coverage(coverage > 0.85)
  ensures: documentation_complete(documentation_quality > 0.8)
)

(plan feature_development_plan
  § steps:
    - analyze_feature_requirements
    - design_implementation_approach
    - create_implementation_components
    - implement_comprehensive_tests
    - create_feature_documentation
    - validate_feature_completion
    - collect_development_feedback
)

(test feature_validation_test
  given: complete_feature_requirements
  when: feature_development_plan_executed
  then: all_acceptance_criteria_met
  and: test_coverage_adequate
  and: documentation_complete
)
EOF

# Create basic CLI wrapper
cat > "$SMARS_DIR/smars-cli.py" << 'EOF'
#!/usr/bin/env python3
"""
SMARS Repository Substrate CLI
Lightweight wrapper for SMARS planning operations in any repository.
"""

import sys
import os
import json
import subprocess
import argparse
from pathlib import Path

def find_smars_agent():
    """Find SMARS agent binary in various locations"""
    possible_paths = [
        "smars-agent",  # In PATH
        "../smars-agent/target/debug/smars-agent",  # Development build
        "../smars-agent/target/release/smars-agent",  # Release build
        str(Path.home() / ".cargo/bin/smars-agent"),  # Cargo install
    ]
    
    for path in possible_paths:
        try:
            result = subprocess.run([path, "--help"], capture_output=True)
            if result.returncode == 0:
                return path
        except (FileNotFoundError, subprocess.SubprocessError):
            continue
    
    return None

def init_plan(plan_name, template="feature"):
    """Initialize a new plan from template"""
    smars_dir = Path(".smars")
    template_path = smars_dir / "templates" / f"{template}-plan.smars.md"
    plan_path = smars_dir / "specs" / f"{plan_name}.smars.md"
    
    if not template_path.exists():
        print(f"❌ Template {template} not found")
        return False
    
    # Copy template to new plan
    with open(template_path) as f:
        template_content = f.read()
    
    # Replace template variables
    plan_content = template_content.replace("${timestamp}", str(int(time.time())))
    plan_content = plan_content.replace("Feature Development Plan Template", f"{plan_name.title()} Development Plan")
    
    os.makedirs(plan_path.parent, exist_ok=True)
    with open(plan_path, 'w') as f:
        f.write(plan_content)
    
    print(f"✅ Created plan: {plan_path}")
    return True

def execute_plan(plan_name, mode="runtime"):
    """Execute a SMARS plan using the agent"""
    smars_agent = find_smars_agent()
    if not smars_agent:
        print("❌ SMARS agent not found. Please install or build smars-agent.")
        return False
    
    smars_dir = Path(".smars")
    plan_path = smars_dir / "specs" / f"{plan_name}.smars.md"
    
    if not plan_path.exists():
        print(f"❌ Plan {plan_name} not found. Use 'smars init {plan_name}' to create it.")
        return False
    
    # Execute with SMARS agent
    cmd = [smars_agent, mode, "--spec", str(plan_path), "--detailed", "--verbose"]
    
    print(f"🚀 Executing plan: {plan_name}")
    print(f"Command: {' '.join(cmd)}")
    
    try:
        result = subprocess.run(cmd, check=True)
        print("✅ Plan execution completed")
        return True
    except subprocess.CalledProcessError as e:
        print(f"❌ Plan execution failed: {e}")
        return False

def list_plans():
    """List available plans"""
    smars_dir = Path(".smars/specs")
    if not smars_dir.exists():
        print("No plans found. Use 'smars init <plan_name>' to create your first plan.")
        return
    
    plans = list(smars_dir.glob("*.smars.md"))
    if not plans:
        print("No plans found.")
        return
    
    print("Available plans:")
    for plan in plans:
        print(f"  - {plan.stem}")

def status():
    """Show SMARS substrate status"""
    smars_dir = Path(".smars")
    
    if not smars_dir.exists():
        print("❌ SMARS not initialized. Run 'smars init' first.")
        return False
    
    print("SMARS Substrate Status")
    print("=" * 30)
    
    # Configuration
    config_path = smars_dir / "config/smars.toml"
    print(f"Configuration: {'✅' if config_path.exists() else '❌'}")
    
    # Plans
    specs_dir = smars_dir / "specs"
    plan_count = len(list(specs_dir.glob("*.smars.md"))) if specs_dir.exists() else 0
    print(f"Plans: {plan_count}")
    
    # Templates
    templates_dir = smars_dir / "templates"
    template_count = len(list(templates_dir.glob("*.smars.md"))) if templates_dir.exists() else 0
    print(f"Templates: {template_count}")
    
    # Agent availability
    agent_available = find_smars_agent() is not None
    print(f"Agent: {'✅' if agent_available else '❌ Install smars-agent'}")
    
    return True

def main():
    parser = argparse.ArgumentParser(description="SMARS Repository Substrate CLI")
    subparsers = parser.add_subparsers(dest='command', help='Commands')
    
    # Init command
    init_parser = subparsers.add_parser('init', help='Initialize new plan')
    init_parser.add_argument('plan_name', help='Plan name')
    init_parser.add_argument('--template', default='feature', help='Plan template')
    
    # Execute command
    exec_parser = subparsers.add_parser('exec', help='Execute plan')
    exec_parser.add_argument('plan_name', help='Plan name')
    exec_parser.add_argument('--mode', default='runtime', choices=['runtime', 'execute'], help='Execution mode')
    
    # List command
    subparsers.add_parser('list', help='List available plans')
    
    # Status command
    subparsers.add_parser('status', help='Show substrate status')
    
    args = parser.parse_args()
    
    if not args.command:
        parser.print_help()
        return
    
    if args.command == 'init':
        init_plan(args.plan_name, args.template)
    elif args.command == 'exec':
        execute_plan(args.plan_name, args.mode)
    elif args.command == 'list':
        list_plans()
    elif args.command == 'status':
        status()

if __name__ == "__main__":
    import time
    main()
EOF

chmod +x "$SMARS_DIR/smars-cli.py"

# Create repository integration script
cat > "$SMARS_DIR/integrate.sh" << 'EOF'
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
EOF

chmod +x "$SMARS_DIR/integrate.sh"

# Create README for the substrate
cat > "$SMARS_DIR/README.md" << 'EOF'
# SMARS Planning Substrate

This directory contains the SMARS (Symbolic Multi-Agent Reasoning System) substrate for this repository. SMARS provides deterministic planning and execution capabilities with reality grounding and comprehensive validation.

## Directory Structure

```
.smars/
├── config/          # SMARS configuration
├── specs/           # SMARS plan specifications  
├── plans/           # Deprecated (kept for compatibility)
├── agents/          # Agent configurations
├── templates/       # Plan templates
├── traces/          # Execution traces (local-only)
├── smars-cli.py     # Repository CLI wrapper
├── integrate.sh     # Repository integration script
└── README.md        # This file
```

## Quick Start

### 1. Check Status
```bash
python .smars/smars-cli.py status
```

### 2. Create a Plan
```bash
python .smars/smars-cli.py init feature-authentication
```

### 3. Execute Plan
```bash
python .smars/smars-cli.py exec feature-authentication
```

### 4. List Plans
```bash
python .smars/smars-cli.py list
```

## Integration

Run the integration script to add shell aliases and repository configuration:

```bash
.smars/integrate.sh
```

After integration, you can use the `smars` command directly:

```bash
smars status
smars init my-feature
smars exec my-feature
```

## Plan Templates

Available templates:
- `feature`: Feature development with requirements, implementation, and validation
- `bugfix`: Bug resolution with root cause analysis and testing
- `refactor`: Code refactoring with safety validation
- `deployment`: Deployment planning with rollback procedures

## Configuration

Edit `.smars/config/smars.toml` to customize:
- Execution parameters (determinism, feedback enforcement)
- Validation settings (contract, artifact, reality validation)
- Agent capabilities (self-auditing, reality simulation)

## Dependencies

Requires SMARS agent binary:
- Install from source or package manager
- Or build from `smars-agent/` directory
- Or use containerized version

## Reality Grounding

SMARS prevents "symbolic hallucination" by:
- Enforcing artifact existence validation
- Requiring concrete feedback collection
- Implementing confidence bounds
- Maintaining reality-simulation alignment

All plan executions produce verifiable artifacts and comprehensive execution traces.
EOF

echo "✅ SMARS substrate initialized successfully"
echo ""
echo "Repository: $REPO_ROOT"
echo "SMARS Directory: $SMARS_DIR"
echo ""
echo "Next steps:"
echo "  1. Run integration: $SMARS_DIR/integrate.sh"
echo "  2. Check status: python $SMARS_DIR/smars-cli.py status"
echo "  3. Create first plan: python $SMARS_DIR/smars-cli.py init my-feature"
echo ""
echo "The SMARS substrate is now ready for use in this repository!"