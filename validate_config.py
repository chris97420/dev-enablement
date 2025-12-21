#!/usr/bin/env python3
"""
Validation script to test configuration loading
Run this to verify your config files are valid before running the main setup
"""

import sys
import json
from pathlib import Path

def test_config_file(filename, expected_type):
    """Test if a config file is valid JSON and has expected structure"""
    config_path = Path(__file__).parent / "config" / filename
    
    print(f"\n{'='*60}")
    print(f"Testing: {filename}")
    print(f"{'='*60}")
    
    # Check if file exists
    if not config_path.exists():
        print(f"❌ File not found: {config_path}")
        return False
    
    print(f"✓ File exists: {config_path}")
    
    # Try to parse JSON
    try:
        with open(config_path, 'r', encoding='utf-8') as f:
            data = json.load(f)
        print(f"✓ Valid JSON")
    except json.JSONDecodeError as e:
        print(f"❌ Invalid JSON: {e}")
        return False
    except Exception as e:
        print(f"❌ Error reading file: {e}")
        return False
    
    # Check type
    if expected_type == "dict":
        if not isinstance(data, dict):
            print(f"❌ Expected dictionary, got {type(data).__name__}")
            return False
        print(f"✓ Valid dictionary with {len(data)} entries")
    
    # File-specific validations
    if filename == "personas.json":
        for persona_id, persona_data in data.items():
            if not all(k in persona_data for k in ["label", "description", "tools", "extensions"]):
                print(f"❌ Persona '{persona_id}' missing required fields")
                return False
        print(f"✓ All personas have required fields (label, description, tools, extensions)")
    
    elif filename == "tools.json":
        for category, tools in data.items():
            for tool_id, tool_data in tools.items():
                if "label" not in tool_data:
                    print(f"❌ Tool '{tool_id}' in category '{category}' missing 'label'")
                    return False
        print(f"✓ All tools have 'label' field")
    
    elif filename == "extensions.json":
        if not all(isinstance(v, str) for v in data.values()):
            print(f"❌ All extension values must be strings")
            return False
        print(f"✓ All extensions have string display names")
    
    print(f"✅ {filename} is valid!")
    return True

def main():
    """Run all validation tests"""
    print("\n" + "="*60)
    print("  Configuration Validation Tool")
    print("="*60)
    
    tests = [
        ("personas.json", "dict"),
        ("tools.json", "dict"),
        ("extensions.json", "dict"),
    ]
    
    results = []
    for filename, expected_type in tests:
        results.append(test_config_file(filename, expected_type))
    
    print("\n" + "="*60)
    print("  Summary")
    print("="*60)
    
    passed = sum(results)
    total = len(results)
    
    if passed == total:
        print(f"✅ All {total} configuration files are valid!")
        print("   You can run setup-dev-env.py with confidence.")
        return 0
    else:
        print(f"❌ {total - passed} configuration file(s) failed validation")
        print("   Please fix the errors before running setup-dev-env.py")
        return 1

if __name__ == "__main__":
    sys.exit(main())
