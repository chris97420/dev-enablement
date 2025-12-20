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
    # Build menu items list
    $menuItems = @()
    
    foreach ($category in $ToolConfig.Keys | Sort-Object) {
        foreach ($winPkgId in $ToolConfig[$category].Keys) {
            $tool = $ToolConfig[$category][$winPkgId]
            
            # Skip platform-specific tools
            if ($IsWin -and $tool.MacPkg -eq $null -and $category -eq 'Productivity' -and $winPkgId -ne 'Microsoft.PowerToys') { continue }
            if ($IsMac -and $tool.WinPkg -eq $null -and $winPkgId -eq 'Microsoft.PowerToys') { continue }
            
            $menuItems += @{
                Category = $category
                Key = $winPkgId
                Label = $tool.Label
                Type = 'Tool'
            }
        }
    }
    
    foreach ($extId in $VSCodeExtensions.Keys | Sort-Object) {
        $ext = $VSCodeExtensions[$extId]
        $menuItems += @{
            Category = 'Extensions'
            Key = $extId
            Label = $ext.Label
            Type = 'Extension'
        }
    }
    
    $selectedIndex = 0
    $continue = $true
    
    # Hide cursor for cleaner display
    [Console]::CursorVisible = $false
    
    function Render-Menu {
        param($selectedIdx)
        
        # Move cursor to top and clear
        [Console]::SetCursorPosition(0, 0)
        
        # Build output as a string array for atomic write
        $output = @()
        $output += "==== Developer Environment Setup - Tool Selection ===="
        $output += ""
        
        # Group items by category
        $currentCategory = ""
        for ($i = 0; $i -lt $menuItems.Count; $i++) {
            $item = $menuItems[$i]
            
            # Show category header if changed
            if ($item.Category -ne $currentCategory) {
                if ($i -gt 0) { $output += "" }
                $output += "[$($item.Category)]"
                $currentCategory = $item.Category
            }
            
            # Get enabled status
            $isEnabled = if ($item.Type -eq 'Extension') {
                $VSCodeExtensions[$item.Key].Enabled
            } else {
                $ToolConfig[$item.Category][$item.Key].Enabled
            }
            
            $status = if ($isEnabled) { "[X]" } else { "[ ]" }
            $cursor = if ($i -eq $selectedIdx) { ">" } else { " " }
            $line = "$cursor $status $($item.Label)"
            
            # Pad line to clear any previous content
            $line = $line.PadRight([Console]::WindowWidth - 1)
            $output += $line
        }
        
        $output += ""
        $output += "Controls:"
        $output += "  ↑/↓ or k/j - Navigate"
        $output += "  Space - Toggle selection"
        $output += "  a - Select all  |  n - Deselect all"
        $output += "  Enter - Continue with installation"
        $output += "  q or Esc - Quit"
        $output += ""
        
        # Write entire screen at once with colors
        [Console]::SetCursorPosition(0, 0)
        $lineNum = 0
        foreach ($line in $output) {
            if ($lineNum -eq 0) {
                Write-Host $line -ForegroundColor Cyan
            } elseif ($line -match '^\[.*\]$') {
                Write-Host $line -ForegroundColor Yellow
            } elseif ($line -match '^Controls:') {
                Write-Host $line -ForegroundColor Cyan
            } elseif ($line -match '^>' -and $line -notmatch '^\s') {
                Write-Host $line -ForegroundColor Cyan
            } elseif ($line -match '^\s+\[X\]') {
                Write-Host $line -ForegroundColor Green
            } elseif ($line -match '^\s+\[\s\]') {
                Write-Host $line -ForegroundColor Gray
            } else {
                Write-Host $line -ForegroundColor White
            }
            $lineNum++
        }
    }
    
    # Initial render
    Clear-Host
    Render-Menu -selectedIdx $selectedIndex
    
    while ($continue) {
        # Read key
        $key = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
        $needsRedraw = $false
        
        switch ($key.VirtualKeyCode) {
            38 { # Up Arrow
                $selectedIndex = if ($selectedIndex -gt 0) { $selectedIndex - 1 } else { $menuItems.Count - 1 }
                $needsRedraw = $true
            }
            40 { # Down Arrow
                $selectedIndex = if ($selectedIndex -lt ($menuItems.Count - 1)) { $selectedIndex + 1 } else { 0 }
                $needsRedraw = $true
            }
            32 { # Spacebar
                $item = $menuItems[$selectedIndex]
                if ($item.Type -eq 'Extension') {
                    $VSCodeExtensions[$item.Key].Enabled = -not $VSCodeExtensions[$item.Key].Enabled
                } else {
                    $ToolConfig[$item.Category][$item.Key].Enabled = -not $ToolConfig[$item.Category][$item.Key].Enabled
                }
                $needsRedraw = $true
            }
            13 { # Enter
                $continue = $false
            }
            27 { # Escape
                [Console]::CursorVisible = $true
                Clear-Host
                Write-Host "Exiting without installation." -ForegroundColor Yellow
                exit 0
            }
        }
        
        # Handle letter keys
        if ($key.Character -match '[a-zA-Z]') {
            switch ($key.Character.ToString().ToLower()) {
                'q' {
                    [Console]::CursorVisible = $true
                    Clear-Host
                    Write-Host "Exiting without installation." -ForegroundColor Yellow
                    exit 0
                }
                'a' {
                    foreach ($category in $ToolConfig.Keys) {
                        foreach ($pkgKey in $ToolConfig[$category].Keys) {
                            $ToolConfig[$category][$pkgKey].Enabled = $true
                        }
                    }
                    foreach ($extKey in $VSCodeExtensions.Keys) {
                        $VSCodeExtensions[$extKey].Enabled = $true
                    }
                    $needsRedraw = $true
                }
                'n' {
                    foreach ($category in $ToolConfig.Keys) {
                        foreach ($pkgKey in $ToolConfig[$category].Keys) {
                            $ToolConfig[$category][$pkgKey].Enabled = $false
                        }
                    }
                    foreach ($extKey in $VSCodeExtensions.Keys) {
                        $VSCodeExtensions[$extKey].Enabled = $false
                    }
                    $needsRedraw = $true
                }
                'k' { # Vim-style up
                    $selectedIndex = if ($selectedIndex -gt 0) { $selectedIndex - 1 } else { $menuItems.Count - 1 }
                    $needsRedraw = $true
                }
                'j' { # Vim-style down
                    $selectedIndex = if ($selectedIndex -lt ($menuItems.Count - 1)) { $selectedIndex + 1 } else { 0 }
                    $needsRedraw = $true
                }
            }
        }
        
        if ($needsRedraw) {
            Render-Menu -selectedIdx $selectedIndex
        }
    }
    
    # Restore cursor
    [Console]::CursorVisible = $true
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