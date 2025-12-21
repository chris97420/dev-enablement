# Portable Developer Environment Setup Script

A **cross-platform, persona-driven developer environment setup** for **Windows 11**, **macOS**, and **Linux**. Works on brand new machines with zero prerequisites!

## ✨ Features

**✅ Bootstrap Support:**
- Works on completely fresh machines
- Automatically installs Python and all dependencies
- Single command to get started

**👤 Developer Personas:**
- **.NET Full-Stack Developer** - C#, ASP.NET Core, Azure, SQL Server
- **Node.js Full-Stack Developer** - JavaScript, Express, React, MongoDB
- **Node.js TypeScript Full-Stack Developer** - TypeScript, Next.js, React
- **Python Full-Stack Developer** - Python, Django/Flask/FastAPI, PostgreSQL
- **Java Full-Stack Developer** - Java, Spring Boot, Maven, PostgreSQL
- **Custom Selection** - Manually choose your tools

**🛠️ Tools Included:**
- **Core:** Git, Node.js, Python, .NET SDK, GitHub CLI, VS Code
- **API & Testing:** Postman, Insomnia, Fiddler
- **Cloud:** Azure CLI, Azure Functions, AWS CLI, Google Cloud SDK, Docker, Terraform, Kubectl
- **Databases:** DBeaver, MongoDB Compass, SQL Server Management Studio (Windows)
- **Languages:** Java (Temurin), Go, Rust, PHP
- **Build Tools:** Maven, Gradle
- **Productivity:** PowerToys (Windows), Rectangle (macOS)

---

## 🚀 Quick Start

### Windows 11
**One command in PowerShell:**
```powershell
iwr -useb "https://raw.githubusercontent.com/chris97420/dev-setup/main/bootstrap.ps1" | iex
```

Or if cloned:
```powershell
.\bootstrap.ps1
```

### macOS
**One command in Terminal:**
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/chris97420/dev-setup/main/bootstrap.sh)
```

Or if cloned:
```bash
chmod +x bootstrap.sh && ./bootstrap.sh
```

### Linux (Debian/Ubuntu)
**One command in Terminal:**
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/chris97420/dev-setup/main/bootstrap.sh)
```

Or if cloned:
```bash
chmod +x bootstrap.sh && ./bootstrap.sh
```

**Note:** Some installations require sudo privileges. You may be prompted for your password.

### What Happens:
1. Installs Python 3, pip, and dependencies
2. Launches interactive setup with persona selection
3. Installs selected tools and VS Code extensions
4. Configures shell enhancements

---

## 📋 Developer Personas

### .NET Full-Stack Developer
- C#, ASP.NET Core, Entity Framework
- .NET SDK, Azure CLI, Azure Functions, SQL Server Management Studio
- C# DevKit, Azure Functions extensions

### Node.js Full-Stack Developer
- JavaScript, Express, React
- Node.js LTS, Docker, MongoDB Compass, DBeaver
- ESLint, Prettier, Docker, MongoDB extensions

### Node.js TypeScript Full-Stack Developer
- TypeScript, Next.js, React
- Node.js LTS, Docker, DBeaver
- ESLint, Prettier, Docker, Tailwind CSS extensions

### Python Full-Stack Developer
- Python, Django/Flask/FastAPI
- Python 3.12, Docker, DBeaver
- Python, Pylance, Debugger, Docker extensions

### Java Full-Stack Developer
- Java, Spring Boot, Maven
- Java 21 (Temurin), Maven, Docker, DBeaver
- Java Extension Pack, Spring Boot Tools, Maven extensions

---

## 🛠️ Advanced Usage

### If Python Already Installed:
```bash
pip install questionary
python setup-dev-env.py
```

### PowerShell Version (Alternative):
```powershell
pwsh setup-dev-env.ps1
```

---

## 📦 VS Code Extensions

Extensions installed based on your persona:

**Core & AI:**
- GitHub Copilot & Copilot Chat
- GitHub Pull Requests & Issues
- Windows AI Studio
- REST Client

**General:**
- Docker, Remote Containers
- ESLint, Prettier

**Language-Specific:**
- **.NET:** C# DevKit, Azure Functions
- **Python:** Python, Pylance, Debugger
- **Java:** Java Extension Pack, Spring Boot Tools, Maven
- **JavaScript/TypeScript:** Tailwind CSS
- **Database:** MongoDB

---

## 🦄 Shell Enhancements

### Windows:
- [Oh My Posh](https://ohmyposh.dev/) - Beautiful PowerShell prompts
- [Terminal-Icons](https://github.com/devblackops/Terminal-Icons) - Colorful file icons
- **Action Required:** Set font to **Cascadia Mono PL** or **FiraCode NF**

### macOS & Linux:
- [Oh My Zsh](https://ohmyz.sh/) - Zsh themes & plugins
- FiraCode Nerd Font installed
- **Action Required:** Set font to **FiraCode Nerd Font**
- Zsh set as default shell

---

## 📝 How It Works

- **Windows:** [winget](https://learn.microsoft.com/en-us/windows/package-manager/winget/) package manager
- **macOS:** [Homebrew](https://brew.sh/) package manager
- **Linux:** [apt](https://wiki.debian.org/Apt) and [snap](https://snapcraft.io/) package managers
- **Extensions:** VS Code `code` CLI
- **Copilot CLI:** npm global install

---

## 🔧 Troubleshooting

**Bootstrap Issues:**
- Windows: May need Administrator privileges
- macOS: May need sudo for Homebrew install
- Linux: Requires sudo privileges for apt/snap installations

**winget not found:**
- Install from Microsoft Store or https://aka.ms/getwinget

**Linux specific:**
- Script supports Debian/Ubuntu-based distributions
- Some packages may require additional repositories (automatically configured)
- For other distributions, adapt package names in `TOOL_CONFIG`

**PATH issues:**
- Restart terminal after installation
- Log out/in if tools still not found

**VS Code CLI not found:**
- Restart terminal or log out/in after VS Code install

---

## 🎨 Customization

**Add Tools:**
Edit `TOOL_CONFIG` dictionary in [setup-dev-env.py](setup-dev-env.py)

**Add Extensions:**
Update `VSCODE_EXTENSIONS` dictionary

**Create Personas:**
Add new entries to `PERSONAS` dictionary with custom toolsets

---

## ⚙️ Requirements

**None for bootstrap!** 

For manual runs: Python 3.8+ and pip

---

Enjoy your ready-to-code setup! 🚀
