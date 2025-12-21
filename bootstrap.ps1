#!/usr/bin/env pwsh
<#
.SYNOPSIS
    Bootstrap script for Windows - Prepares the system to run the main setup script
.DESCRIPTION
    This script installs all necessary dependencies on a brand new Windows machine:
    - Python 3 (via winget or Microsoft Store)
    - pip
    - questionary Python package
    Then launches the main setup-dev-env.py script
.EXAMPLE
    pwsh bootstrap.ps1
#>

$ErrorActionPreference = "Stop"

Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Developer Environment Bootstrap (Windows)" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Check if running as Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Host "⚠️  Not running as Administrator. Some installations may require elevation." -ForegroundColor Yellow
    Write-Host ""
}

# Function to check if a command exists
function Test-Command {
    param($Command)
    $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

# Step 1: Check/Install winget
Write-Host "📦 Checking for winget..." -ForegroundColor Green
if (-not (Test-Command "winget")) {
    Write-Host "   Installing winget (App Installer)..." -ForegroundColor Yellow
    try {
        # Try to install App Installer from Microsoft Store
        Start-Process "ms-windows-store://pdp/?ProductId=9NBLGGH4NNS1" -Wait
        Write-Host "   ⚠️  Please install 'App Installer' from Microsoft Store and re-run this script" -ForegroundColor Yellow
        exit 1
    } catch {
        Write-Host "   ❌ Could not open Microsoft Store. Please install winget manually." -ForegroundColor Red
        Write-Host "   Visit: https://aka.ms/getwinget" -ForegroundColor Yellow
        exit 1
    }
} else {
    Write-Host "   ✓ winget is available" -ForegroundColor Green
}

# Step 2: Check/Install Python 3
Write-Host ""
Write-Host "🐍 Checking for Python 3..." -ForegroundColor Green
if (-not (Test-Command "python")) {
    Write-Host "   Installing Python 3.12..." -ForegroundColor Yellow
    try {
        winget install --id Python.Python.3.12 --source winget --silent --accept-source-agreements --accept-package-agreements
        Write-Host "   ✅ Python 3 installed" -ForegroundColor Green
        
        # Refresh environment variables
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        
        # Verify installation
        if (-not (Test-Command "python")) {
            Write-Host "   ⚠️  Python installed but not in PATH. Please restart your terminal." -ForegroundColor Yellow
            exit 1
        }
    } catch {
        Write-Host "   ❌ Failed to install Python" -ForegroundColor Red
        Write-Host "   Error: $_" -ForegroundColor Red
        exit 1
    }
} else {
    $pythonVersion = python --version 2>&1
    Write-Host "   ✓ Python is available: $pythonVersion" -ForegroundColor Green
}

# Step 3: Ensure pip is available and up-to-date
Write-Host ""
Write-Host "📦 Checking pip..." -ForegroundColor Green
try {
    python -m pip --version | Out-Null
    Write-Host "   ✓ pip is available" -ForegroundColor Green
    
    Write-Host "   Upgrading pip..." -ForegroundColor Yellow
    python -m pip install --upgrade pip --quiet
    Write-Host "   ✅ pip upgraded" -ForegroundColor Green
} catch {
    Write-Host "   Installing pip..." -ForegroundColor Yellow
    python -m ensurepip --upgrade
}

# Step 4: Install questionary package
Write-Host ""
Write-Host "📦 Installing Python dependencies..." -ForegroundColor Green
try {
    python -m pip install questionary --quiet
    Write-Host "   ✅ questionary installed" -ForegroundColor Green
} catch {
    Write-Host "   ❌ Failed to install questionary" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Red
    exit 1
}

# Step 5: Launch main setup script
Write-Host ""
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host "  Launching Main Setup Script" -ForegroundColor Cyan
Write-Host "============================================================" -ForegroundColor Cyan
Write-Host ""

# Determine if we're running from a file or via iex
$scriptPath = $MyInvocation.MyCommand.Path
$isRemoteExecution = [string]::IsNullOrEmpty($scriptPath)

if (-not $isRemoteExecution) {
    $scriptDir = Split-Path -Parent $scriptPath
    $mainScript = Join-Path $scriptDir "setup-dev-env.py"
} else {
    $mainScript = $null
}

# If the main script is not found locally (e.g., running via iwr | iex), download from GitHub and run
if ($mainScript -and (Test-Path $mainScript)) {
    python $mainScript
} else {
    Write-Host "❗ setup-dev-env.py not found next to bootstrap. Downloading from GitHub..." -ForegroundColor Yellow
    try {
        $repoRawBase = "https://raw.githubusercontent.com/chris97420/dev-enablement/main/"
        $tempDir = Join-Path $env:TEMP "dev-enablement-setup"
        $tempConfigDir = Join-Path $tempDir "config"
        
        # Create temp directories
        New-Item -ItemType Directory -Force -Path $tempConfigDir | Out-Null
        
        # Download main script
        $tempMain = Join-Path $tempDir "setup-dev-env.py"
        Invoke-WebRequest -Uri ($repoRawBase + "setup-dev-env.py") -UseBasicParsing -OutFile $tempMain
        Write-Host "   ✅ Downloaded setup-dev-env.py" -ForegroundColor Green
        
        # Download config files
        $configFiles = @("personas.json", "tools.json", "extensions.json")
        foreach ($file in $configFiles) {
            $configUrl = $repoRawBase + "config/" + $file
            $configPath = Join-Path $tempConfigDir $file
            Invoke-WebRequest -Uri $configUrl -UseBasicParsing -OutFile $configPath
            Write-Host "   ✅ Downloaded config/$file" -ForegroundColor Green
        }
        
        if (Test-Path $tempMain) {
            python $tempMain
        } else {
            Write-Host "   ❌ Failed to download setup-dev-env.py" -ForegroundColor Red
            exit 1
        }
    } catch {
        Write-Host "   ❌ Error downloading files: $_" -ForegroundColor Red
        exit 1
    }
}
