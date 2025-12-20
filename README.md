# Portable Developer Environment Setup Script

This script provides a **portable, easy-to-run, cross-platform setup** for developers on **Windows 11** and **macOS**, with sensible defaults and fallback options.

**Tools installed:**
- Git
- Node.js (LTS)
- Python
- .NET SDK
- GitHub CLI (`gh`)
- Visual Studio Code

**VS Code Extensions:**
- GitHub Copilot
- GitHub Copilot Chat
- GitHub Pull Requests & Issues
- GitHub Theme
- Windows AI Studio

**Additional features:**
- GitHub Copilot CLI (npm global tool)
- **Windows:** Installs Oh My Posh, Terminal-Icons PowerShell module, sets up PowerShell profile
- **macOS:** Installs Oh My Zsh, FiraCode Nerd Font, sets Zsh as shell

---

## 🚀 Quick Usage

**Run in PowerShell Core (`pwsh`) on Windows 11 or macOS.**
```powershell
pwsh -c "iwr -useb 'https://gist.githubusercontent.com/chris97420/54c3aed8398c9b0644c31473a23368ad/raw/0525c93e02c12fd88a5c1435249304bb2db9360f/setup-dev-env.ps1' | iex"
```
---

## How Does It Work?

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