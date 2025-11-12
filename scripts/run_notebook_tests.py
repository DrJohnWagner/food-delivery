#!/usr/bin/env python3
"""
Wrapper script to run notebook tests with notebook argument.

Usage:
    python scripts/run_notebook_tests.py [notebook.ipynb] [pytest_args...]

Examples:
    python scripts/run_notebook_tests.py
    python scripts/run_notebook_tests.py ideal_notebook.ipynb
    python scripts/run_notebook_tests.py notebook.ipynb -v
    python scripts/run_notebook_tests.py ideal_notebook.ipynb -k test_notebook_exec
"""

import os
import sys
import subprocess
from pathlib import Path

def main():
    """Run pytest with notebook environment variable set."""
    
    # Parse arguments
    args = sys.argv[1:]  # Remove script name
    
    # Default notebook
    notebook = "notebook.ipynb"
    pytest_args = []
    
    # If first argument is a .ipynb file, use it as notebook
    if args and args[0].endswith('.ipynb'):
        notebook = args[0]
        pytest_args = args[1:]  # Rest are pytest arguments
    else:
        pytest_args = args  # All arguments are pytest arguments
    
    # Validate notebook exists
    if not Path(notebook).exists():
        print(f"❌ Notebook '{notebook}' not found!")
        print("Available notebooks:")
        for nb in Path('.').glob('*.ipynb'):
            print(f"   {nb}")
        return 1
    
    # Set environment variable and run pytest
    env = os.environ.copy()
    env['TEST_NOTEBOOK'] = notebook
    
    # Build pytest command
    cmd = [sys.executable, '-m', 'pytest', 'test_notebook.py'] + pytest_args
    
    print(f"🧪 Testing notebook: {notebook}")
    print(f"🚀 Running: {' '.join(cmd)}")
    print()
    
    # Run pytest with environment
    try:
        result = subprocess.run(cmd, env=env)
        return result.returncode
    except KeyboardInterrupt:
        print("\n⚠️  Test interrupted by user")
        return 130

if __name__ == "__main__":
    sys.exit(main())