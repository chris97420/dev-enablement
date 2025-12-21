# Developer Environment Setup - AI Agent Guide

## Project Overview
Cross-platform developer environment bootstrap and setup tool that installs tools and VS Code extensions based on developer personas. Supports Windows (winget), macOS (Homebrew), and Linux (apt/snap) with zero prerequisites—works on brand-new machines.

## Architecture

### Entry Points
- **[bootstrap.ps1](../bootstrap.ps1)** - Windows bootstrap: Installs Python 3, pip, questionary, then launches setup-dev-env.py
- **[bootstrap.sh](../bootstrap.sh)** - macOS/Linux bootstrap: Installs Homebrew (macOS)/apt packages (Linux), Python 3, then launches setup-dev-env.py  
- **[setup-dev-env.py](../setup-dev-env.py)** - Main orchestrator: Interactive persona selection, tool/extension installation, shell enhancements

### Three-Phase Flow
1. **Bootstrap Phase** (OS-specific scripts) → Ensures Python 3 + questionary available
2. **Selection Phase** (`setup-dev-env.py`) → Interactive menus for persona/tools/extensions using `questionary` library
3. **Installation Phase** (`setup-dev-env.py`) → Platform-specific package manager calls + VS Code CLI extension installs

## Key Data Structures

### PERSONAS Dictionary
Five pre-configured developer personas (`.NET`, `Node.js`, `Node.js TypeScript`, `Python`, `Java`) plus `custom`. Each persona defines:
- `tools`: Array of package IDs (e.g., `"Git.Git"`, `"OpenJS.NodeJS.LTS"`)
- `extensions`: Array of VS Code extension IDs (e.g., `"GitHub.copilot"`, `"ms-python.python"`)

**Example persona** ([setup-dev-env.py#L40-50](../setup-dev-env.py#L40-L50)):
```python
"python-fullstack": {
    "label": "Python Full-Stack Developer",
    "description": "Python, Django/Flask/FastAPI, PostgreSQL, Docker",
    "tools": ["Git.Git", "Python.Python.3.12", "Docker.DockerDesktop", ...],
    "extensions": ["GitHub.copilot", "ms-python.python", ...]
}
```

### TOOL_CONFIG Dictionary
Multi-level structure: `Category → Tool ID → Metadata`. Each tool defines:
- `label`: Display name
- `mac_pkg`/`type`: Homebrew package/type (`formula` or `cask`)
- `linux_pkg`/`linux_snap`/`linux_source`: apt package name, snap availability, custom repo
- Windows uses tool ID directly with winget

**Example** ([setup-dev-env.py#L127-131](../setup-dev-env.py#L127-L131)):
```python
"Microsoft.DotNet.SDK.9": {
    "label": ".NET SDK",
    "mac_pkg": "dotnet-sdk",
    "type": "formula",
    "linux_pkg": "dotnet-sdk-9.0",
    "linux_source": "microsoft"
}
```

## Platform-Specific Patterns

### Windows: winget Commands
- Check installed: `winget list --exact --id <tool_id>`
- Install: `winget install --id <tool_id> --source winget --accept-source-agreements --accept-package-agreements -e --silent`
- Shell setup: Installs Oh My Posh (via winget) + Terminal-Icons PowerShell module

### macOS: Homebrew
- Check installed: `brew list [--cask] <pkg>`
- Install: `brew install [--cask] <pkg>`
- Shell setup: Oh My Zsh + FiraCode Nerd Font

### Linux: apt + snap
- **Repository setup first** ([setup-dev-env.py#L445-483](../setup-dev-env.py#L445-L483)): Adds Microsoft, GitHub CLI, HashiCorp repos before installation
- Check installed: `dpkg -l <pkg>` or `snap list <pkg>`
- Install: `sudo apt install -y <pkg>` or `sudo snap install <pkg> [--classic]`
- Shell setup: Zsh (apt) + Oh My Zsh + FiraCode Nerd Font

## Critical Workflows

### Adding New Tools
1. Add entry to `TOOL_CONFIG` under appropriate category with all platform package managers:
   ```python
   "Vendor.ToolName": {
       "label": "Display Name",
       "mac_pkg": "homebrew-package", "type": "formula",  # or "cask"
       "linux_pkg": "apt-package", "linux_snap": False,
       "linux_source": None  # or "microsoft"/"hashicorp"/etc. if custom repo needed
   }
   ```
2. If Windows-only/macOS-only, set other platforms to `None`
3. If Linux needs custom repo, add repository setup code to `setup_linux_repositories()`

### Adding New Personas
1. Add entry to `PERSONAS` dict with `label`, `description`, `tools` (array of tool IDs from `TOOL_CONFIG`), `extensions` (array of VS Code extension IDs from `VSCODE_EXTENSIONS`)
2. Tools/extensions will auto-populate in selection UI with pre-checked state

### Adding VS Code Extensions
Add to `VSCODE_EXTENSIONS` dict: `"publisher.extension-id": "Display Name"`

## Testing & Debugging

### Local Testing
```bash
# Windows
.\bootstrap.ps1

# macOS/Linux
chmod +x bootstrap.sh && ./bootstrap.sh

# If Python/questionary already installed
python setup-dev-env.py
```

### Remote Bootstrap Testing
Bootstrap scripts support downloading `setup-dev-env.py` from GitHub if not found locally (see [bootstrap.ps1#L120-141](../bootstrap.ps1#L120-L141) and [bootstrap.sh#L143-158](../bootstrap.sh#L143-L158)).

Update URLs to point to your repo: `REPO_RAW_BASE="https://raw.githubusercontent.com/chris97420/dev-setup/main/"`

## Common Pitfalls

- **PATH refresh**: Windows requires `$env:Path` refresh after winget installs ([bootstrap.ps1#L68](../bootstrap.ps1#L68))
- **Platform exclusions**: Always check IS_WINDOWS/IS_MACOS/IS_LINUX before adding platform-specific tools to selection UI ([setup-dev-env.py#L286-295](../setup-dev-env.py#L286-L295))
- **VS Code CLI location**: Windows uses `%LOCALAPPDATA%\Programs\Microsoft VS Code\bin\code.cmd`, Unix uses `code` ([setup-dev-env.py#L609-616](../setup-dev-env.py#L609-L616))
- **Linux repos must be added first**: Call `setup_linux_repositories()` before installing tools that need Microsoft/HashiCorp packages

## Shell Enhancements
- **Windows**: Oh My Posh + Terminal-Icons → Manual step: Set font to "Cascadia Mono PL" or "FiraCode NF"
- **macOS/Linux**: Oh My Zsh + FiraCode Nerd Font → Manual step: Set terminal font + log out/in for zsh default shell
