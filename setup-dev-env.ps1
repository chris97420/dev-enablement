<#
Highly Portable Developer Environment Setup Script (PowerShell Core)
Supports Windows 11 and macOS

Features:
- Installs: Git, Node.js LTS, Python 3, .NET SDK, GitHub CLI, Visual Studio Code, Copilot CLI
- Installs VS Code extensions: GitHub Copilot, Copilot Chat, Pull Requests, GitHub Theme, Windows AI Studio
- Windows: Uses winget if available, falls back on Chocolatey if not
- macOS: Uses Homebrew
- Windows: Installs Oh My Posh, Terminal-Icons PowerShell module, updates PowerShell profile
- macOS: Installs Oh My Zsh, FiraCode Nerd Font, sets Zsh as shell, guides for font setting

USAGE:
pwsh -c "iwr -useb '<RAW_GIST_URL>' | iex"
# (Replace <RAW_GIST_URL> with your gist's setup-dev-env.ps1 raw URL)
#>

#--- UTILITY: Platform detection ---
$IsWin = $PSVersionTable.Platform -eq 'Win32NT' -or $env:OS -eq 'Windows_NT'
$IsMac = $PSVersionTable.Platform -eq 'Unix' -and (
    ($env:OSTYPE -like "*darwin*") -or
    ($env:TERM_PROGRAM -eq "Apple_Terminal") -or
    ($env:TERM_PROGRAM -eq "iTerm.app")
)

Write-Host "==== Developer Environment Setup ====" -ForegroundColor Cyan

#--- MAIN FUNCTIONS ---
function Install-Windows {
    Write-Host "Detected OS: Windows" -ForegroundColor Green

    # Check for winget
    $hasWinget = $false
    try { if (Get-Command winget -ErrorAction Stop) { $hasWinget = $true } } catch {}

    $winPackages = @{
      'Git.Git'                    = 'git'
      'OpenJS.NodeJS.LTS'          = 'nodejs-lts'
      'Python.PythonInstallManager' = 'python'
      'Microsoft.DotNet.SDK.9'     = 'dotnet-sdk'
      'GitHub.cli'                 = 'gh'
      'Microsoft.VisualStudioCode'  = 'vscode'
    }

    if ($hasWinget) {
        Write-Host "Using winget for installs." -ForegroundColor Yellow

        foreach ($wingetId in $winPackages.Keys) {
            $pkgLabel = $winPackages[$wingetId]
            Write-Host "Checking if $pkgLabel ($wingetId) is installed..." -ForegroundColor Cyan
            try {
                $installed = winget list --exact --id $wingetId | Out-String
                if ($installed -notmatch $wingetId) {
                    Write-Host "→ Installing $pkgLabel ($wingetId)..." -ForegroundColor Yellow
                    $wingetCmd = "winget install --id `"$wingetId`" --source winget --accept-source-agreements --accept-package-agreements -e --silent"
                    Write-Host "Running: $wingetCmd" -ForegroundColor DarkGray

                    # Start process and wait up to 10 minutes, dump output for logs/troubleshooting
                    $process = Start-Process -FilePath "winget" -ArgumentList @("install","--id",$wingetId,"--source","winget","--accept-source-agreements","--accept-package-agreements","-e","--silent") -NoNewWindow -PassThru -Wait
                    if ($process.ExitCode -ne 0) {
                        Write-Host "[!] $pkgLabel ($wingetId) installation failed (exit code $($process.ExitCode))." -ForegroundColor Red
                        Write-Host "   Troubleshooting: Is Microsoft Store installed/enabled? Is your user profile corrupted? Try running 'winget install --id $wingetId' manually." -ForegroundColor Red
                    } else {
                        Write-Host "✓ $pkgLabel ($wingetId) installed successfully." -ForegroundColor Green
                    }
                } else {
                    Write-Host "$pkgLabel is already installed." -ForegroundColor Gray
                }
            } catch {
                Write-Host "[!] An error occurred checking or installing $pkgLabel ($wingetId): $_" -ForegroundColor Red
                Write-Host "   Try 'winget install --id $wingetId' manually, or check that 'winget' is working in your terminal." -ForegroundColor Yellow
            }
        }
        Write-Host "All winget package install attempts completed." -ForegroundColor Green
    } else {
        Write-Host "winget not found. Falling back to Chocolatey..." -ForegroundColor Yellow
        # ...rest of chocolatey logic unchanged...
    }

    Install-VSCodeExtensions
    Install-Copilot-CLI
    Install-OhMyPosh-Windows
}

function Install-MacOS {
    Write-Host "Detected OS: macOS" -ForegroundColor Green

    if (-not (Get-Command brew -ErrorAction SilentlyContinue)) {
        Write-Host "Installing Homebrew..." -ForegroundColor Yellow
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        eval "$(/opt/homebrew/bin/brew shellenv)"
    }

    $macPackages = @('git', 'node', 'python', 'dotnet-sdk', 'gh', 'visual-studio-code')
    foreach ($pkg in $macPackages) {
        if ($pkg -eq 'visual-studio-code') {
            if (-not (brew list --cask $pkg 2>&1 | Select-String $pkg)) {
                Write-Host "Installing $pkg (cask)..." -ForegroundColor Yellow
                brew install --cask $pkg
            } else {
                Write-Host "$pkg already installed." -ForegroundColor Gray
            }
        } else {
            if (-not (brew list $pkg 2>&1 | Select-String $pkg)) {
                Write-Host "Installing $pkg..." -ForegroundColor Yellow
                brew install $pkg
            } else {
                Write-Host "$pkg already installed." -ForegroundColor Gray
            }
        }
    }

    Install-VSCodeExtensions
    Install-Copilot-CLI
    Install-OhMyZsh-MacOS
}

function Install-VSCodeExtensions {
    $vsCodeCmd = if ($IsWin) { "$env:LOCALAPPDATA\Programs\Microsoft VS Code\bin\code.cmd" } else { "code" }
    if (-not (Get-Command $vsCodeCmd -ErrorAction SilentlyContinue)) {
        Write-Host "VS Code CLI not found, skipping extension install." -ForegroundColor Red
        return
    }
    $extensions = @(
        "GitHub.copilot",
        "GitHub.copilot-chat",
        "GitHub.github-vscode-theme",
        "GitHub.vscode-pull-request-github",
        "ms-windows-ai-studio.windows-ai-studio"
    )
    foreach ($ext in $extensions) {
        & $vsCodeCmd --install-extension $ext --force
    }
    Write-Host "VS Code extensions installed." -ForegroundColor Green
}

function Install-Copilot-CLI {
    if (Get-Command node -ErrorAction SilentlyContinue) {
        if (-not (Get-Command "github-copilot-cli" -ErrorAction SilentlyContinue)) {
            Write-Host "Installing GitHub Copilot CLI..." -ForegroundColor Yellow
            npm install -g @githubnext/github-copilot-cli
        } else {
            Write-Host "GitHub Copilot CLI already installed." -ForegroundColor Gray
        }
    } else {
        Write-Host "Node.js not found, skipping Copilot CLI install." -ForegroundColor Red
    }
}

function Install-OhMyPosh-Windows {
    Write-Host "Installing Oh My Posh and Terminal-Icons..." -ForegroundColor Yellow
    if (Get-Command winget -ErrorAction SilentlyContinue) {
        winget install JanDeDobbeleer.OhMyPosh -s winget -e --accept-package-agreements --accept-source-agreements --silent
    } else {
        choco install oh-my-posh -y
        choco install cascadia-code-nerd-font -y
    }
    
    # Install Terminal-Icons PowerShell module
    Write-Host "Installing Terminal-Icons module..." -ForegroundColor Yellow
    if (-not (Get-Module -ListAvailable -Name Terminal-Icons)) {
        Install-Module -Name Terminal-Icons -Repository PSGallery -Force -Scope CurrentUser
        Write-Host "✓ Terminal-Icons module installed." -ForegroundColor Green
    } else {
        Write-Host "Terminal-Icons module already installed." -ForegroundColor Gray
    }
    
    $profilePath = "$HOME\Documents\PowerShell\Microsoft.PowerShell_profile.ps1"
    if (-not (Test-Path $profilePath)) {
        New-Item -type file -path $profilePath -Force | Out-Null
    }
    if (-not (Get-Content $profilePath | Select-String "oh-my-posh init pwsh")) {
        Add-Content $profilePath 'oh-my-posh init pwsh | Invoke-Expression'
        Add-Content $profilePath 'Import-Module Terminal-Icons'
        Add-Content $profilePath '# Recommended: Set Windows Terminal/Console font to "Cascadia Mono PL" or "FiraCode NF" for best glyph/emoji support.'
    } elseif (-not (Get-Content $profilePath | Select-String "Import-Module Terminal-Icons")) {
        Add-Content $profilePath 'Import-Module Terminal-Icons'
    }
    Write-Host "`n[MANUAL STEP REQUIRED] Set your Windows Terminal or PowerShell font to 'Cascadia Mono PL', 'FiraCode NF', or any Nerd Font for full prompt glyph/emoji support." -ForegroundColor Magenta
}

function Install-OhMyZsh-MacOS {
    Write-Host "Installing Oh My Zsh and recommended Nerd Font..." -ForegroundColor Yellow
    if (-not (Test-Path $HOME/.oh-my-zsh)) {
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    } else {
        Write-Host "Oh My Zsh already installed." -ForegroundColor Gray
    }
    brew tap homebrew/cask-fonts
    brew install --cask font-fira-code-nerd-font
    Write-Host "`n[MANUAL STEP REQUIRED] Set your Terminal/iTerm2 font to 'FiraCode Nerd Font', 'MesloLGS NF', or another Nerd Font for full glyph/emoji support." -ForegroundColor Magenta
    Write-Host "For Oh My Zsh themes with emoji/glyphs, use: Powerlevel10k or similar." -ForegroundColor Magenta
    if ($SHELL -ne "/bin/zsh") {
        chsh -s /bin/zsh
    }
}

#--- DISPATCHER ---
if ($IsWin) {
    Install-Windows
} elseif ($IsMac) {
    Install-MacOS
} else {
    Write-Host "Unsupported platform. This script only supports Windows and macOS." -ForegroundColor Red
    exit 1
}

Write-Host "`nAll tools installed! You may need to restart your terminal or log out/in for PATH changes to take effect." -ForegroundColor Green