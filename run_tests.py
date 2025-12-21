#!/usr/bin/env python3
"""
Test runner script for the dev-enablement project.
This script makes it easy to run tests with a single command.
"""

import sys
import subprocess
import os

def main():
    """Run the test suite"""
    print("=" * 60)
    print("  Running Dev-Enablement Test Suite")
    print("=" * 60)
    print()
    
    # Check if pytest is installed
    try:
        import pytest
    except ImportError:
        print("❌ pytest not found. Installing test dependencies...")
        subprocess.check_call([sys.executable, "-m", "pip", "install", "-r", "requirements-test.txt"])
        import pytest
    
    # Run pytest with recommended options
    args = [
        "test_setup_dev_env.py",
        "-v",
        "--cov=setup-dev-env.py",
        "--cov-report=term-missing",
        "--cov-report=html",
        "--tb=short"
    ]
    
    # Add any additional arguments passed to this script
    args.extend(sys.argv[1:])
    
    print("Running: pytest " + " ".join(args))
    print()
    
    # Run tests
    exit_code = pytest.main(args)
    
    if exit_code == 0:
        print()
        print("=" * 60)
        print("  ✅ All tests passed!")
        print("  📊 Coverage report generated in htmlcov/index.html")
        print("=" * 60)
    else:
        print()
        print("=" * 60)
        print("  ❌ Some tests failed")
        print("=" * 60)
    
    return exit_code

if __name__ == "__main__":
    sys.exit(main())
