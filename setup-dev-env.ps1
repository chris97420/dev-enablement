<#
Highly Portable Developer Environment Setup Script (PowerShell Core)
Supports Windows 11 and macOS

Features:
- Interactive tool selection menu
- Installs: Git, Node.js LTS, Python 3, .NET SDK, GitHub CLI, Visual Studio Code, Cloud tools, and more
- Installs VS Code extensions: GitHub Copilot, Copilot Chat, Pull Requests, Azure tools, Docker, and more
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

#--- TOOL CONFIGURATION ---
$ToolConfig = @{
    'Core' = @{
        'Git.Git'                    = @{ Enabled = $true; Label = 'Git'; MacPkg = 'git'; Type = 'formula' }
        'OpenJS.NodeJS.LTS'          = @{ Enabled = $true; Label = 'Node.js (LTS)'; MacPkg = 'node'; Type = 'formula' }
        'Python.PythonInstallManager' = @{ Enabled = $true; Label = 'Python'; MacPkg = 'python'; Type = 'formula' }
        'Microsoft.DotNet.SDK.9'     = @{ Enabled = $true; Label = '.NET SDK'; MacPkg = 'dotnet-sdk'; Type = 'formula' }
        'GitHub.cli'                 = @{ Enabled = $true; Label = 'GitHub CLI'; MacPkg = 'gh'; Type = 'formula' }
        'Microsoft.VisualStudioCode'  = @{ Enabled = $true; Label = 'Visual Studio Code'; MacPkg = 'visual-studio-code'; Type = 'cask' }
    }
    'API & Testing' = @{
        'Postman.Postman'            = @{ Enabled = $true; Label = 'Postman'; MacPkg = 'postman'; Type = 'cask' }
        'Insomnia.Insomnia'          = @{ Enabled = $true; Label = 'Insomnia'; MacPkg = 'insomnia'; Type = 'cask' }
        'Fiddler.FiddlerEverywhere'  = @{ Enabled = $true; Label = 'Fiddler Everywhere'; MacPkg = 'fiddler-everywhere'; Type = 'cask' }
    }
    'Cloud & Infrastructure' = @{
        'Microsoft.AzureCLI'         = @{ Enabled = $true; Label = 'Azure CLI'; MacPkg = 'azure-cli'; Type = 'formula' }
        'Microsoft.AzureFunctionsCoreTools' = @{ Enabled = $true; Label = 'Azure Functions Core Tools'; MacPkg = 'azure-functions-core-tools'; Type = 'formula' }
        'Amazon.AWSCLI'              = @{ Enabled = $true; Label = 'AWS CLI'; MacPkg = 'awscli'; Type = 'formula' }
        'Google.CloudSDK'            = @{ Enabled = $true; Label = 'Google Cloud SDK'; MacPkg = 'google-cloud-sdk'; Type = 'formula' }
        'Hashicorp.Terraform'        = @{ Enabled = $true; Label = 'Terraform'; MacPkg = 'terraform'; Type = 'formula' }
        'Kubernetes.kubectl'         = @{ Enabled = $true; Label = 'Kubectl'; MacPkg = 'kubectl'; Type = 'formula' }
    }
    'Containers & Databases' = @{
        'Docker.DockerDesktop'       = @{ Enabled = $true; Label = 'Docker Desktop'; MacPkg = 'docker'; Type = 'cask' }
        'Microsoft.AzureDataStudio'  = @{ Enabled = $true; Label = 'Azure Data Studio'; MacPkg = 'azure-data-studio'; Type = 'cask' }
    }
    'Productivity' = @{
        'Microsoft.PowerToys'        = @{ Enabled = $true; Label = 'PowerToys (Windows only)'; MacPkg = $null; Type = 'windows-only' }
        'Rectangle'                  = @{ Enabled = $true; Label = 'Rectangle (macOS only)'; MacPkg = 'rectangle'; Type = 'cask'; WinPkg = $null }
    }
}

$VSCodeExtensions = @{
    'GitHub.copilot'                        = @{ Enabled = $true; Label = 'GitHub Copilot' }
    'GitHub.copilot-chat'                   = @{ Enabled = $true; Label = 'GitHub Copilot Chat' }
    'GitHub.github-vscode-theme'            = @{ Enabled = $true; Label = 'GitHub Theme' }
    'GitHub.vscode-pull-request-github'     = @{ Enabled = $true; Label = 'GitHub Pull Requests' }
    'ms-windows-ai-studio.windows-ai-studio' = @{ Enabled = $true; Label = 'Windows AI Studio' }
    'humao.rest-client'                     = @{ Enabled = $true; Label = 'REST Client' }
    'ms-azuretools.vscode-azurefunctions'   = @{ Enabled = $true; Label = 'Azure Functions' }
    'ms-vscode.azure-account'               = @{ Enabled = $true; Label = 'Azure Account' }
    'dbaeumer.vscode-eslint'                = @{ Enabled = $true; Label = 'ESLint' }
    'esbenp.prettier-vscode'                = @{ Enabled = $true; Label = 'Prettier' }
    'ms-vscode-remote.remote-containers'    = @{ Enabled = $true; Label = 'Remote Containers' }
    'ms-azuretools.vscode-docker'           = @{ Enabled = $true; Label = 'Docker' }
}

#--- INTERACTIVE MENU ---
function Show-InteractiveMenu {
    $continue = $true
    
    while ($continue) {
        Clear-Host
        Write-Host "==== Developer Environment Setup - Tool Selection ====" -ForegroundColor Cyan
        Write-Host ""
        
        # Display Tools by Category
        $index = 1
        $menuMap = @{}
        
        foreach ($category in $ToolConfig.Keys | Sort-Object) {
            Write-Host "[$category]" -ForegroundColor Yellow
            foreach ($winPkgId in $ToolConfig[$category].Keys) {
                $tool = $ToolConfig[$category][$winPkgId]
                
                # Skip platform-specific tools
                if ($IsWin -and $tool.MacPkg -eq $null -and $category -eq 'Productivity' -and $winPkgId -ne 'Microsoft.PowerToys') { continue }
                if ($IsMac -and $tool.WinPkg -eq $null -and $winPkgId -eq 'Microsoft.PowerToys') { continue }
                
                $status = if ($tool.Enabled) { "[X]" } else { "[ ]" }
                $color = if ($tool.Enabled) { "Green" } else { "Gray" }
                Write-Host "  $index. $status $($tool.Label)" -ForegroundColor $color
                $menuMap[$index] = @{ Category = $category; Key = $winPkgId }
                $index++
            }
            Write-Host ""
        }
        
        # Display VS Code Extensions
        Write-Host "[VS Code Extensions]" -ForegroundColor Yellow
        $extStartIndex = $index
        foreach ($extId in $VSCodeExtensions.Keys | Sort-Object) {
            $ext = $VSCodeExtensions[$extId]
            $status = if ($ext.Enabled) { "[X]" } else { "[ ]" }
            $color = if ($ext.Enabled) { "Green" } else { "Gray" }
            Write-Host "  $index. $status $($ext.Label)" -ForegroundColor $color
            $menuMap[$index] = @{ Category = 'Extensions'; Key = $extId }
            $index++
        }
        
        Write-Host ""
        Write-Host "Commands:" -ForegroundColor Cyan
        Write-Host "  Enter number to toggle" -ForegroundColor White
        Write-Host "  'all' - Select all" -ForegroundColor White
        Write-Host "  'none' - Deselect all" -ForegroundColor White
        Write-Host "  'continue' or 'c' - Proceed with installation" -ForegroundColor White
        Write-Host "  'quit' or 'q' - Exit without installing" -ForegroundColor White
        Write-Host ""
        
        $choice = Read-Host "Enter your choice"
        
        switch -Regex ($choice) {
            '^(continue|c)$' {
                $continue = $false
            }
            '^(quit|q)$' {
                Write-Host "Exiting without installation." -ForegroundColor Yellow
                exit 0
            }
            '^all$' {
                foreach ($category in $ToolConfig.Keys) {
                    foreach ($key in $ToolConfig[$category].Keys) {
                        $ToolConfig[$category][$key].Enabled = $true
                    }
                }
                foreach ($key in $VSCodeExtensions.Keys) {
                    $VSCodeExtensions[$key].Enabled = $true
                }
            }
            '^none$' {
                foreach ($category in $ToolConfig.Keys) {
                    foreach ($key in $ToolConfig[$category].Keys) {
                        $ToolConfig[$category][$key].Enabled = $false
                    }
                }
                foreach ($key in $VSCodeExtensions.Keys) {
                    $VSCodeExtensions[$key].Enabled = $false
                }
            }
            '^\d+$' {
                $num = [int]$choice
                if ($menuMap.ContainsKey($num)) {
                    $item = $menuMap[$num]
                    if ($item.Category -eq 'Extensions') {
                        $VSCodeExtensions[$item.Key].Enabled = -not $VSCodeExtensions[$item.Key].Enabled
                    } else {
                        $ToolConfig[$item.Category][$item.Key].Enabled = -not $ToolConfig[$item.Category][$item.Key].Enabled
                    }
                } else {
                    Write-Host "Invalid selection" -ForegroundColor Red
                    Start-Sleep -Seconds 1
                }
            }
            default {
                Write-Host "Invalid input" -ForegroundColor Red
                Start-Sleep -Seconds 1
            }
        }
    }
    
    Clear-Host
    Write-Host "==== Starting Installation ====" -ForegroundColor Cyan
    Write-Host ""
}

#--- MAIN FUNCTIONS ---
function Install-Windows {
    Write-Host "Detected OS: Windows" -ForegroundColor Green

    # Check for winget
    $hasWinget = $false
    try { if (Get-Command winget -ErrorAction Stop) { $hasWinget = $true } } catch {}

    if ($hasWinget) {
        Write-Host "Using winget for installs." -ForegroundColor Yellow

        foreach ($category in $ToolConfig.Keys) {
            foreach ($wingetId in $ToolConfig[$category].Keys) {
                $tool = $ToolConfig[$category][$wingetId]
                
                # Skip if not enabled or macOS-only
                if (-not $tool.Enabled) { continue }
                if ($wingetId -eq 'Rectangle') { continue }
                
                Write-Host "Checking if $($tool.Label) ($wingetId) is installed..." -ForegroundColor Cyan
                try {
                    $installed = winget list --exact --id $wingetId | Out-String
                    if ($installed -notmatch $wingetId) {
                        Write-Host "→ Installing $($tool.Label) ($wingetId)..." -ForegroundColor Yellow
                        $process = Start-Process -FilePath "winget" -ArgumentList @("install","--id",$wingetId,"--source","winget","--accept-source-agreements","--accept-package-agreements","-e","--silent") -NoNewWindow -PassThru -Wait
                        if ($process.ExitCode -ne 0) {
                            Write-Host "[!] $($tool.Label) ($wingetId) installation failed (exit code $($process.ExitCode))." -ForegroundColor Red
                        } else {
                            Write-Host "✓ $($tool.Label) ($wingetId) installed successfully." -ForegroundColor Green
                        }
                    } else {
                        Write-Host "$($tool.Label) is already installed." -ForegroundColor Gray
                    }
                } catch {
                    Write-Host "[!] An error occurred checking or installing $($tool.Label) ($wingetId): $_" -ForegroundColor Red
                }
            }
        }
        Write-Host "All winget package install attempts completed." -ForegroundColor Green
    } else {
        Write-Host "winget not found. Falling back to Chocolatey..." -ForegroundColor Yellow
      'Microsoft.AzureCLI'         = 'azure-cli'
      'Microsoft.AzureFunctionsCoreTools' = 'azure-functions-core-tools'
      'Docker.DockerDesktop'       = 'docker-desktop'
      'Insomnia.Insomnia'          = 'insomnia'
      'Fiddler.FiddlerEverywhere'  = 'fiddler-everywhere'
      'Microsoft.AzureDataStudio'  = 'azure-data-studio'
      'Hashicorp.Terraform'        = 'terraform'
      'Kubernetes.kubectl'         = 'kubectl'
      'Microsoft.PowerToys'        = 'powertoys'
      'Amazon.AWSCLI'              = 'aws-cli'
      'Google.CloudSDK'            = 'google-cloud-sdk'
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
        # Chocolatey not implemented with interactive menu - please use winget
        Write-Host "Please install winget or manually install tools." -ForegroundColor Red
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

    # Install formula packages
    foreach ($category in $ToolConfig.Keys) {
        foreach ($winPkgId in $ToolConfig[$category].Keys) {
            $tool = $ToolConfig[$category][$winPkgId]
            
            # Skip if not enabled, Windows-only, or not a formula
            if (-not $tool.Enabled) { continue }
            if ($winPkgId -eq 'Microsoft.PowerToys') { continue }
            if (-not $tool.MacPkg) { continue }
            
            $pkg = $tool.MacPkg
            
            if ($tool.Type -eq 'formula') {
                if (-not (brew list $pkg 2>&1 | Select-String $pkg)) {
                    Write-Host "Installing $($tool.Label)..." -ForegroundColor Yellow
                    brew install $pkg
                } else {
                    Write-Host "$($tool.Label) already installed." -ForegroundColor Gray
                }
            } elseif ($tool.Type -eq 'cask') {
                if (-not (brew list --cask $pkg 2>&1 | Select-String $pkg)) {
                    Write-Host "Installing $($tool.Label) (cask)..." -ForegroundColor Yellow
                    brew install --cask $pkg
                } else {
                    Write-Host "$($tool.Label) already installed." -ForegroundColor Gray
                }
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
    
    foreach ($extId in $VSCodeExtensions.Keys) {
        $ext = $VSCodeExtensions[$extId]
        if ($ext.Enabled) {
            Write-Host "Installing $($ext.Label)..." -ForegroundColor Yellow
            & $vsCodeCmd --install-extension $extId --force
        }
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
Show-InteractiveMenu

if ($IsWin) {
    Install-Windows
} elseif ($IsMac) {
    Install-MacOS
} else {
    Write-Host "Unsupported platform. This script only supports Windows and macOS." -ForegroundColor Red
    exit 1
}

Write-Host "`nAll tools installed! You may need to restart your terminal or log out/in for PATH changes to take effect." -ForegroundColor Green