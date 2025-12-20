# Portable Developer Environment Setup Script

This script provides a **portable, easy-to-run, cross-platform setup** for developers on **Windows 11** and **macOS**, with an **interactive menu** to select tools and sensible defaults.

## ✨ Features

**Interactive Tool Selection:**
- Choose which tools and extensions to install
- Toggle selections with simple number inputs
- Select all, deselect all, or customize your setup
- No unwanted software installed!

**Tools installed:**
- Git
- Node.js (LTS)
- Python
- .NET SDK
- GitHub CLI (`gh`)
- Visual Studio Code
- Postman (API testing)
- Azure CLI
- Azure Functions Core Tools
- Docker Desktop
- Insomnia (API testing)
- Fiddler Everywhere (network debugging)
- Azure Data Studio (database management)
- Terraform (Infrastructure as Code)
- Kubectl (Kubernetes CLI)
- PowerToys (Windows only - productivity utilities)
- Rectangle (macOS only - window management)
- AWS CLI (Amazon Web Services)
- Google Cloud SDK (Google Cloud Platform)

---

## How Does It Work?

**VS Code Extensions:**
- GitHub Copilot
- GitHub Copilot Chat
- GitHub Pull Requests & Issues
- GitHub Theme
- Windows AI Studio
- REST Client
- Azure Functions
- Azure Account
- ESLint
- Prettier
- Remote Containers
- Docker

**Additional features:**
- GitHub Copilot CLI (npm global tool)
- **Windows:** Installs Oh My Posh, Terminal-Icons PowerShell module, sets up PowerShell profile
- **macOS:** Installs Oh My Zsh, FiraCode Nerd Font, sets Zsh as shell

---

## 🚀 Quick Usage

**Run in PowerShell Core (`pwsh`) on Windows 11 or macOS.**
```powershell
pwsh -c "iwr -useb 'https://raw.githubusercontent.com/chris97420/dev-setup/refs/heads/main/setup-dev-env.ps1' | iex"
```

The script will display an interactive menu where you can:
- **Enter a number** to toggle that tool on/off
- Type **'all'** to select everything
- Type **'none'** to deselect everything  
- Type **'continue'** or **'c'** to start installation
- Type **'quit'** or **'q'** to exit without changes
---

## 📦 Available Tools

The interactive menu organizes tools into categories:

- **Windows 11:** Installs/updates tools first with [winget](https://learn.microsoft.com/en-us/windows/package-manager/winget/), otherwise falls back on [Chocolatey](https://chocolatey.org/).
- **macOS:** Uses [Homebrew](https://brew.sh/).
- **VS Code Extensions:** Installs using the `code` command.
- **Copilot CLI:** Globally installed via `npm`.

---

## 🦄 Prompt Glyphs/Emoji Supported!

### Windows:
- Installs [Oh My Posh](https://ohmyposh.dev/) for beautiful PowerShell prompts.
- Installs [Terminal-Icons](https://github.com/devblackops/Terminal-Icons) PowerShell module for colorful file/folder icons in directory listings.
- **Manual step required:**  
  Set the font of your Windows Terminal or PowerShell window to **Cascadia Mono PL**, **FiraCode NF**, or another Nerd Font for full glyph/emoji support.

### macOS:
- Installs [Oh My Zsh](https://ohmyz.sh/) (Zsh themes & plugins).
- Installs **FiraCode Nerd Font** for best compatibility.
- **Manual step required:**  
  Set your Terminal/iTerm2 font to **FiraCode Nerd Font**, **MesloLGS NF**, or another Nerd Font via Preferences.
- **Zsh shell will be set as default** (if it isn't already).

**Why?**  
Many modern prompts (and Copilot, etc) use powerline/emoji/nerd fonts.  
You’ll only see the “full experience” after you update your terminal’s font.

---

## Requirements

- **PowerShell Core** (`pwsh`)
    - Windows 11: Pre-installed.
    - macOS:  
      ```sh
      brew install --cask powershell
      ```
- **VS Code:** Automatically installed, but you may need to relaunch your terminal or log out/in for the `code` command to appear.

---

## Troubleshooting

- You may need to run **as Administrator** or confirm permissions.
- If you see “command not found: pwsh”, install PowerShell Core.
- On first run, VS Code may not yet be in your PATH – close/reopen terminal or log out/in, then rerun the script to install extensions if needed.

---

## Customization

- Fork this script on [GitHub Gist](https://gist.github.com/) and add your favorite tools or configuration steps.
- To add more VS Code extensions, list their IDs in the `$extensions` array inside the script.

---

Enjoy your ready-to-code setup! 🚀
