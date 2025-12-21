#!/usr/bin/env bash
# Bootstrap script for macOS and Linux - Prepares the system to run the main setup script
# This script installs all necessary dependencies on a brand new machine:
# - macOS: Homebrew, Python 3, pip, questionary
# - Linux: Python 3, pip, questionary (using apt)
# Then launches the main setup-dev-env.py script

set -e

# Detect OS
OS="Unknown"
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS="macOS"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS="Linux"
fi

echo ""
echo "============================================================"
echo "  Developer Environment Bootstrap ($OS)"
echo "============================================================"
echo ""

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# macOS-specific setup
setup_macos() {
    # Step 1: Check/Install Homebrew
    echo "🍺 Checking for Homebrew..."
    if ! command_exists brew; then
        echo "   Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ $(uname -m) == "arm64" ]]; then
            echo "   Adding Homebrew to PATH (Apple Silicon)..."
            echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/opt/homebrew/bin/brew shellenv)"
        else
            echo 'eval "$(/usr/local/bin/brew shellenv)"' >> ~/.zprofile
            eval "$(/usr/local/bin/brew shellenv)"
        fi
        
        echo "   ✅ Homebrew installed"
    else
        echo "   ✓ Homebrew is available"
    fi

    # Step 2: Update Homebrew
    echo ""
    echo "📦 Updating Homebrew..."
    brew update >/dev/null 2>&1 || true
    echo "   ✓ Homebrew updated"

    # Step 3: Check/Install Python 3
    echo ""
    echo "🐍 Checking for Python 3..."
    if ! command_exists python3; then
        echo "   Installing Python 3..."
        brew install python@3.12
        echo "   ✅ Python 3 installed"
    else
        PYTHON_VERSION=$(python3 --version)
        echo "   ✓ Python is available: $PYTHON_VERSION"
    fi
}

# Linux-specific setup
setup_linux() {
    # Step 1: Update package list
    echo "📦 Updating package list..."
    sudo apt update
    echo "   ✓ Package list updated"

    # Step 2: Check/Install Python 3
    echo ""
    echo "🐍 Checking for Python 3..."
    if ! command_exists python3; then
        echo "   Installing Python 3..."
        sudo apt install -y python3 python3-pip python3-venv
        echo "   ✅ Python 3 installed"
    else
        PYTHON_VERSION=$(python3 --version)
        echo "   ✓ Python is available: $PYTHON_VERSION"
    fi

    # Step 3: Ensure pip is installed
    echo ""
    echo "📦 Checking pip..."
    if ! command_exists pip3 && ! python3 -m pip --version >/dev/null 2>&1; then
        echo "   Installing pip..."
        sudo apt install -y python3-pip
        echo "   ✅ pip installed"
    else
        echo "   ✓ pip is available"
    fi
}

# Run OS-specific setup
if [ "$OS" == "macOS" ]; then
    setup_macos
elif [ "$OS" == "Linux" ]; then
    setup_linux
else
    echo "❌ Unsupported operating system: $OSTYPE"
    echo "   This script supports macOS and Linux (Debian/Ubuntu) only."
    exit 1
fi

# Step 4: Ensure pip is available and up-to-date
echo ""
echo "📦 Checking pip..."
if ! python3 -m pip --version >/dev/null 2>&1; then
    echo "   Installing pip..."
    python3 -m ensurepip --upgrade
fi

echo "   ✓ pip is available"
echo "   Upgrading pip..."
python3 -m pip install --upgrade pip --quiet
echo "   ✅ pip upgraded"

# Step 5: Install questionary package
echo ""
echo "📦 Installing Python dependencies..."
python3 -m pip install questionary --quiet
echo "   ✅ questionary installed"

# Step 6: Launch main setup script
echo ""
echo "============================================================"
echo "  Launching Main Setup Script"
echo "============================================================"
echo ""

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
MAIN_SCRIPT="$SCRIPT_DIR/setup-dev-env.py"

# If the main script is not found locally (e.g., running via curl | bash), download from GitHub and run
if [ -f "$MAIN_SCRIPT" ]; then
    python3 "$MAIN_SCRIPT"
else
    echo "❗ setup-dev-env.py not found next to bootstrap. Downloading from GitHub..."
    REPO_RAW_BASE="https://raw.githubusercontent.com/chris97420/dev-setup/main/"
    REMOTE_MAIN="${REPO_RAW_BASE}setup-dev-env.py"
    TEMP_MAIN="/tmp/setup-dev-env.py"
    if curl -fsSL "$REMOTE_MAIN" -o "$TEMP_MAIN"; then
        echo "   ✅ Downloaded setup-dev-env.py"
        python3 "$TEMP_MAIN"
    else
        echo "   ❌ Failed to download setup-dev-env.py"
        exit 1
    fi
fi
