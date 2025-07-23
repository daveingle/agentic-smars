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
