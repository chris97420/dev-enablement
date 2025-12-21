#!/usr/bin/env python3
"""
Highly Portable Developer Environment Setup Script (Python)
Supports Windows 11 and macOS

Features:
- Beautiful interactive menu with arrow key navigation
- Installs: Git, Node.js LTS, Python 3, .NET SDK, GitHub CLI, Visual Studio Code, Cloud tools, and more
- Installs VS Code extensions: GitHub Copilot, Copilot Chat, Pull Requests, Azure tools, Docker, and more
- Windows: Uses winget if available
- macOS: Uses Homebrew
- Windows: Installs Oh My Posh, Terminal-Icons PowerShell module
- macOS: Installs Oh My Zsh, FiraCode Nerd Font

USAGE:
python3 setup-dev-env.py
"""

import subprocess
import sys
import platform
import os
from pathlib import Path

# Check for required modules and install if missing
try:
    import questionary
    from questionary import Separator, Choice
except ImportError:
    print("Installing required dependencies...")
    subprocess.check_call([sys.executable, "-m", "pip", "install", "questionary"])
    import questionary
    from questionary import Separator, Choice

# Platform detection
IS_WINDOWS = platform.system() == "Windows"
IS_MACOS = platform.system() == "Darwin"

# Developer Personas
PERSONAS = {
    "dotnet-fullstack": {
        "label": ".NET Full-Stack Developer",
        "description": "C#, ASP.NET Core, Azure, SQL Server, Entity Framework",
        "tools": [
            "Git.Git", "Microsoft.DotNet.SDK.9", "Microsoft.VisualStudioCode",
            "Microsoft.AzureCLI", "Microsoft.Azure.FunctionsCoreTools",
            "Docker.DockerDesktop", "Microsoft.SQLServer.SSMS",
            "Postman.Postman", "GitHub.cli"
        ],
        "extensions": [
            "GitHub.copilot", "GitHub.copilot-chat", "ms-dotnettools.csharp",
            "ms-dotnettools.csdevkit", "ms-azuretools.vscode-azurefunctions",
            "ms-vscode.azure-account", "ms-azuretools.vscode-docker",
            "humao.rest-client", "GitHub.vscode-pull-request-github"
        ]
    },
    "nodejs-fullstack": {
        "label": "Node.js Full-Stack Developer",
        "description": "JavaScript, Express, React, MongoDB, PostgreSQL",
        "tools": [
            "Git.Git", "OpenJS.NodeJS.LTS", "Microsoft.VisualStudioCode",
            "Docker.DockerDesktop", "Postman.Postman", "GitHub.cli",
            "dbeaver.dbeaver", "MongoDB.MongoDBCompass"
        ],
        "extensions": [
            "GitHub.copilot", "GitHub.copilot-chat", "dbaeumer.vscode-eslint",
            "esbenp.prettier-vscode", "ms-azuretools.vscode-docker",
            "humao.rest-client", "GitHub.vscode-pull-request-github",
            "mongodb.mongodb-vscode", "ms-vscode-remote.remote-containers"
        ]
    },
    "nodejs-typescript-fullstack": {
        "label": "Node.js TypeScript Full-Stack Developer",
        "description": "TypeScript, Express, React, Next.js, PostgreSQL",
        "tools": [
            "Git.Git", "OpenJS.NodeJS.LTS", "Microsoft.VisualStudioCode",
            "Docker.DockerDesktop", "Postman.Postman", "GitHub.cli",
            "dbeaver.dbeaver"
        ],
        "extensions": [
            "GitHub.copilot", "GitHub.copilot-chat", "dbaeumer.vscode-eslint",
            "esbenp.prettier-vscode", "ms-azuretools.vscode-docker",
            "humao.rest-client", "GitHub.vscode-pull-request-github",
            "ms-vscode-remote.remote-containers", "bradlc.vscode-tailwindcss"
        ]
    },
    "python-fullstack": {
        "label": "Python Full-Stack Developer",
        "description": "Python, Django/Flask/FastAPI, PostgreSQL, Docker",
        "tools": [
            "Git.Git", "Python.Python.3.12", "Microsoft.VisualStudioCode",
            "Docker.DockerDesktop", "Postman.Postman", "GitHub.cli",
            "dbeaver.dbeaver"
        ],
        "extensions": [
            "GitHub.copilot", "GitHub.copilot-chat", "ms-python.python",
            "ms-python.vscode-pylance", "ms-python.debugpy",
            "ms-azuretools.vscode-docker", "humao.rest-client",
            "GitHub.vscode-pull-request-github", "ms-vscode-remote.remote-containers"
        ]
    },
    "java-fullstack": {
        "label": "Java Full-Stack Developer",
        "description": "Java, Spring Boot, Maven, PostgreSQL, Docker",
        "tools": [
            "Git.Git", "EclipseAdoptium.Temurin.21", "Microsoft.VisualStudioCode",
            "Apache.Maven", "Docker.DockerDesktop", "Postman.Postman",
            "GitHub.cli", "dbeaver.dbeaver"
        ],
        "extensions": [
            "GitHub.copilot", "GitHub.copilot-chat", "vscjava.vscode-java-pack",
            "vscjava.vscode-spring-boot-dashboard", "vmware.vscode-spring-boot",
            "vscjava.vscode-maven", "ms-azuretools.vscode-docker",
            "humao.rest-client", "GitHub.vscode-pull-request-github"
        ]
    },
    "custom": {
        "label": "Custom Selection",
        "description": "Manually select all tools and extensions",
        "tools": [],
        "extensions": []
    }
}

# Tool configuration
TOOL_CONFIG = {
    "Core": {
        "Git.Git": {"label": "Git", "mac_pkg": "git", "type": "formula"},
        "OpenJS.NodeJS.LTS": {"label": "Node.js (LTS)", "mac_pkg": "node", "type": "formula"},
        "Python.Python.3.12": {"label": "Python 3", "mac_pkg": "python@3.12", "type": "formula"},
        "Microsoft.DotNet.SDK.9": {"label": ".NET SDK", "mac_pkg": "dotnet-sdk", "type": "formula"},
        "GitHub.cli": {"label": "GitHub CLI", "mac_pkg": "gh", "type": "formula"},
        "Microsoft.VisualStudioCode": {"label": "Visual Studio Code", "mac_pkg": "visual-studio-code", "type": "cask"},
    },
    "API & Testing": {
        "Postman.Postman": {"label": "Postman", "mac_pkg": "postman", "type": "cask"},
        "Insomnia.Insomnia": {"label": "Insomnia", "mac_pkg": "insomnia", "type": "cask"},
        "Telerik.Fiddler.Classic": {"label": "Fiddler", "mac_pkg": "fiddler-everywhere", "type": "cask"},
    },
    "Cloud & Infrastructure": {
        "Microsoft.AzureCLI": {"label": "Azure CLI", "mac_pkg": "azure-cli", "type": "formula"},
        "Microsoft.Azure.FunctionsCoreTools": {"label": "Azure Functions Core Tools", "mac_pkg": "azure-functions-core-tools", "type": "formula"},
        "Amazon.AWSCLI": {"label": "AWS CLI", "mac_pkg": "awscli", "type": "formula"},
        "Google.CloudSDK": {"label": "Google Cloud SDK", "mac_pkg": "google-cloud-sdk", "type": "formula"},
        "Hashicorp.Terraform": {"label": "Terraform", "mac_pkg": "terraform", "type": "formula"},
        "Kubernetes.kubectl": {"label": "Kubectl", "mac_pkg": "kubectl", "type": "formula"},
    },
    "Containers & Databases": {
        "Docker.DockerDesktop": {"label": "Docker Desktop", "mac_pkg": "docker", "type": "cask"},
        "dbeaver.dbeaver": {"label": "DBeaver Community", "mac_pkg": "dbeaver-community", "type": "cask"},
        "Microsoft.SQLServer.SSMS": {"label": "SQL Server Management Studio (Windows)", "mac_pkg": None, "type": "windows-only"},
        "MongoDB.MongoDBCompass": {"label": "MongoDB Compass", "mac_pkg": "mongodb-compass", "type": "cask"},
    },
    "Programming Languages": {
        "EclipseAdoptium.Temurin.21": {"label": "Java 21 (Temurin)", "mac_pkg": "temurin", "type": "cask"},
        "GoLang.Go": {"label": "Go", "mac_pkg": "go", "type": "formula"},
        "Rustlang.Rust.MSVC": {"label": "Rust", "mac_pkg": "rust", "type": "formula"},
        "PHP.PHP": {"label": "PHP", "mac_pkg": "php", "type": "formula"},
    },
    "Build Tools": {
        "Apache.Maven": {"label": "Apache Maven", "mac_pkg": "maven", "type": "formula"},
        "Gradle.Gradle": {"label": "Gradle", "mac_pkg": "gradle", "type": "formula"},
    },
    "Productivity": {
        "Microsoft.PowerToys": {"label": "PowerToys (Windows only)", "mac_pkg": None, "type": "windows-only"},
        "Rectangle": {"label": "Rectangle (macOS only)", "mac_pkg": "rectangle", "type": "cask", "win_pkg": None},
    },
}

VSCODE_EXTENSIONS = {
    # Core GitHub & AI
    "GitHub.copilot": "GitHub Copilot",
    "GitHub.copilot-chat": "GitHub Copilot Chat",
    "GitHub.github-vscode-theme": "GitHub Theme",
    "GitHub.vscode-pull-request-github": "GitHub Pull Requests",
    "ms-windows-ai-studio.windows-ai-studio": "Windows AI Studio",
    
    # General Development
    "humao.rest-client": "REST Client",
    "ms-azuretools.vscode-docker": "Docker",
    "ms-vscode-remote.remote-containers": "Remote Containers",
    
    # Azure
    "ms-azuretools.vscode-azurefunctions": "Azure Functions",
    "ms-vscode.azure-account": "Azure Account",
    
    # JavaScript/TypeScript
    "dbaeumer.vscode-eslint": "ESLint",
    "esbenp.prettier-vscode": "Prettier",
    "bradlc.vscode-tailwindcss": "Tailwind CSS",
    
    # .NET
    "ms-dotnettools.csharp": "C# Dev Kit",
    "ms-dotnettools.csdevkit": "C# DevKit",
    
    # Python
    "ms-python.python": "Python",
    "ms-python.vscode-pylance": "Pylance",
    "ms-python.debugpy": "Python Debugger",
    
    # Java
    "vscjava.vscode-java-pack": "Java Extension Pack",
    "vscjava.vscode-spring-boot-dashboard": "Spring Boot Dashboard",
    "vmware.vscode-spring-boot": "Spring Boot Tools",
    "vscjava.vscode-maven": "Maven for Java",
    
    # Database
    "mongodb.mongodb-vscode": "MongoDB",
}


def print_header(text):
    """Print a styled header"""
    print(f"\n{'=' * 60}")
    print(f"  {text}")
    print(f"{'=' * 60}\n")


def check_command_exists(command):
    """Check if a command exists in PATH"""
    try:
        subprocess.run([command, "--version"], capture_output=True, check=False)
        return True
    except FileNotFoundError:
        return False


def run_command(command, shell=False, check=True):
    """Run a command and return the result"""
    try:
        result = subprocess.run(
            command,
            shell=shell,
            capture_output=True,
            text=True,
            check=check
        )
        return result.returncode == 0, result.stdout, result.stderr
    except Exception as e:
        return False, "", str(e)


def select_persona():
    """Interactive persona selection"""
    print_header("Developer Environment Setup - Persona Selection")
    
    choices = []
    for persona_id, persona_info in PERSONAS.items():
        choices.append(Choice(
            title=f"{persona_info['label']} - {persona_info['description']}",
            value=persona_id
        ))
    
    selected_persona = questionary.select(
        "Choose a developer persona (pre-configured toolset):",
        choices=choices,
        style=questionary.Style([
            ('question', 'fg:cyan bold'),
            ('highlighted', 'fg:cyan bold'),
            ('selected', 'fg:green bold'),
        ])
    ).ask()
    
    if selected_persona is None:
        print("\nInstallation cancelled.")
        sys.exit(0)
    
    return selected_persona


def select_tools(persona_id=None):
    """Interactive tool selection with beautiful UI"""
    print_header("Developer Environment Setup - Tool Selection")
    
    # Get pre-selected tools based on persona
    preselected_tools = set()
    preselected_extensions = set()
    
    if persona_id and persona_id != "custom":
        persona = PERSONAS[persona_id]
        preselected_tools = set(persona["tools"])
        preselected_extensions = set(persona["extensions"])
        print(f"📋 Persona: {persona['label']}")
        print(f"   {persona['description']}\n")
    
    choices = []
    
    # Add tools by category
    for category, tools in TOOL_CONFIG.items():
        choices.append(Separator(f"=== {category} ==="))
        for tool_id, tool_info in tools.items():
            # Skip platform-specific tools
            if IS_WINDOWS and tool_id == "Rectangle":
                continue
            if IS_MACOS and tool_id == "Microsoft.PowerToys":
                continue
            if IS_MACOS and tool_id == "Microsoft.SQLServer.SSMS":
                continue
            
            # Check if tool should be pre-selected
            is_checked = tool_id in preselected_tools or (persona_id == "custom")
            
            choices.append(Choice(
                title=tool_info["label"],
                value=("tool", category, tool_id),
                checked=is_checked
            ))
    
    # Add VS Code extensions
    choices.append(Separator("=== VS Code Extensions ==="))
    for ext_id, ext_label in VSCODE_EXTENSIONS.items():
        # Check if extension should be pre-selected
        is_checked = ext_id in preselected_extensions or (persona_id == "custom")
        
        choices.append(Choice(
            title=ext_label,
            value=("extension", ext_id),
            checked=is_checked
        ))
    
    selected = questionary.checkbox(
        "Select tools to install (Space to toggle, Enter to confirm):",
        choices=choices,
        style=questionary.Style([
            ('separator', 'fg:yellow bold'),
            ('checkbox-selected', 'fg:cyan bold'),
            ('checkbox', 'fg:white'),
            ('selected', 'fg:cyan bold'),
        ])
    ).ask()
    
    if selected is None:
        print("\nInstallation cancelled.")
        sys.exit(0)
    
    # Parse selections
    selected_tools = {}
    selected_extensions = []
    
    for item in selected:
        if item[0] == "tool":
            category, tool_id = item[1], item[2]
            if category not in selected_tools:
                selected_tools[category] = []
            selected_tools[category].append(tool_id)
        elif item[0] == "extension":
            selected_extensions.append(item[1])
    
    return selected_tools, selected_extensions


def install_windows_tools(selected_tools):
    """Install tools on Windows using winget"""
    print_header("Installing Tools on Windows")
    
    if not check_command_exists("winget"):
        print("❌ winget not found. Please install winget or manually install tools.")
        return
    
    print("✓ Using winget for installations\n")
    
    for category, tool_ids in selected_tools.items():
        for tool_id in tool_ids:
            tool_info = TOOL_CONFIG[category][tool_id]
            print(f"📦 Installing {tool_info['label']}...")
            
            # Check if already installed
            success, stdout, _ = run_command(
                ["winget", "list", "--exact", "--id", tool_id],
                check=False
            )
            
            if tool_id in stdout:
                print(f"   ✓ {tool_info['label']} is already installed")
                continue
            
            # Install
            success, _, stderr = run_command(
                [
                    "winget", "install",
                    "--id", tool_id,
                    "--source", "winget",
                    "--accept-source-agreements",
                    "--accept-package-agreements",
                    "-e",
                    "--silent"
                ],
                check=False
            )
            
            if success:
                print(f"   ✅ {tool_info['label']} installed successfully")
            else:
                print(f"   ❌ Failed to install {tool_info['label']}")


def install_macos_tools(selected_tools):
    """Install tools on macOS using Homebrew"""
    print_header("Installing Tools on macOS")
    
    if not check_command_exists("brew"):
        print("📦 Installing Homebrew...")
        run_command(
            '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"',
            shell=True
        )
    
    print("✓ Using Homebrew for installations\n")
    
    for category, tool_ids in selected_tools.items():
        for tool_id in tool_ids:
            tool_info = TOOL_CONFIG[category][tool_id]
            
            if not tool_info.get("mac_pkg"):
                continue
            
            pkg = tool_info["mac_pkg"]
            print(f"📦 Installing {tool_info['label']}...")
            
            # Check if already installed
            if tool_info["type"] == "cask":
                success, stdout, _ = run_command(
                    ["brew", "list", "--cask", pkg],
                    check=False
                )
            else:
                success, stdout, _ = run_command(
                    ["brew", "list", pkg],
                    check=False
                )
            
            if success:
                print(f"   ✓ {tool_info['label']} is already installed")
                continue
            
            # Install
            if tool_info["type"] == "cask":
                success, _, _ = run_command(
                    ["brew", "install", "--cask", pkg],
                    check=False
                )
            else:
                success, _, _ = run_command(
                    ["brew", "install", pkg],
                    check=False
                )
            
            if success:
                print(f"   ✅ {tool_info['label']} installed successfully")
            else:
                print(f"   ❌ Failed to install {tool_info['label']}")


def install_vscode_extensions(selected_extensions):
    """Install VS Code extensions"""
    print_header("Installing VS Code Extensions")
    
    # Find VS Code CLI
    if IS_WINDOWS:
        vscode_cmd = os.path.join(
            os.environ.get("LOCALAPPDATA", ""),
            "Programs", "Microsoft VS Code", "bin", "code.cmd"
        )
        if not os.path.exists(vscode_cmd):
            vscode_cmd = "code"
    else:
        vscode_cmd = "code"
    
    if not check_command_exists(vscode_cmd):
        print("❌ VS Code CLI not found. Skipping extension installation.")
        return
    
    for ext_id in selected_extensions:
        ext_label = VSCODE_EXTENSIONS[ext_id]
        print(f"📦 Installing {ext_label}...")
        success, _, _ = run_command(
            [vscode_cmd, "--install-extension", ext_id, "--force"],
            check=False
        )
        if success:
            print(f"   ✅ {ext_label} installed")


def install_copilot_cli():
    """Install GitHub Copilot CLI"""
    print_header("Installing GitHub Copilot CLI")
    
    if not check_command_exists("node"):
        print("❌ Node.js not found. Skipping Copilot CLI installation.")
        return
    
    if check_command_exists("github-copilot-cli"):
        print("✓ GitHub Copilot CLI is already installed")
        return
    
    print("📦 Installing GitHub Copilot CLI...")
    success, _, _ = run_command(
        ["npm", "install", "-g", "@githubnext/github-copilot-cli"],
        check=False
    )
    
    if success:
        print("✅ GitHub Copilot CLI installed successfully")


def setup_windows_shell():
    """Setup Oh My Posh and Terminal-Icons on Windows"""
    print_header("Setting Up Windows Shell Enhancements")
    
    # Install Oh My Posh
    print("📦 Installing Oh My Posh...")
    if check_command_exists("winget"):
        run_command(
            [
                "winget", "install",
                "JanDeDobbeleer.OhMyPosh",
                "-s", "winget", "-e",
                "--accept-package-agreements",
                "--accept-source-agreements",
                "--silent"
            ],
            check=False
        )
    
    # Install Terminal-Icons via PowerShell
    print("📦 Installing Terminal-Icons module...")
    run_command(
        [
            "pwsh", "-Command",
            "Install-Module -Name Terminal-Icons -Repository PSGallery -Force -Scope CurrentUser"
        ],
        check=False
    )
    
    # Setup PowerShell profile
    profile_path = Path.home() / "Documents" / "PowerShell" / "Microsoft.PowerShell_profile.ps1"
    profile_path.parent.mkdir(parents=True, exist_ok=True)
    
    if not profile_path.exists():
        profile_path.touch()
    
    content = profile_path.read_text() if profile_path.exists() else ""
    
    if "oh-my-posh init pwsh" not in content:
        with profile_path.open("a") as f:
            f.write("\noh-my-posh init pwsh | Invoke-Expression\n")
            f.write("Import-Module Terminal-Icons\n")
            f.write('# Set Windows Terminal font to "Cascadia Mono PL" or "FiraCode NF" for best experience.\n')
    
    print("\n⚠️  MANUAL STEP REQUIRED:")
    print("    Set your Windows Terminal font to 'Cascadia Mono PL' or 'FiraCode NF'")


def setup_macos_shell():
    """Setup Oh My Zsh on macOS"""
    print_header("Setting Up macOS Shell Enhancements")
    
    # Install Oh My Zsh
    if not Path.home().joinpath(".oh-my-zsh").exists():
        print("📦 Installing Oh My Zsh...")
        run_command(
            'sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended',
            shell=True,
            check=False
        )
    
    # Install Nerd Font
    print("📦 Installing FiraCode Nerd Font...")
    run_command(["brew", "tap", "homebrew/cask-fonts"], check=False)
    run_command(["brew", "install", "--cask", "font-fira-code-nerd-font"], check=False)
    
    print("\n⚠️  MANUAL STEP REQUIRED:")
    print("    Set your Terminal/iTerm2 font to 'FiraCode Nerd Font'")


def main():
    """Main execution flow"""
    print_header("Developer Environment Setup")
    print(f"Platform: {platform.system()}")
    print(f"Python: {sys.version}")
    
    if not IS_WINDOWS and not IS_MACOS:
        print("❌ Unsupported platform. This script only supports Windows and macOS.")
        sys.exit(1)
    
    # Select persona first
    persona_id = select_persona()
    
    # Interactive tool selection with persona pre-selection
    selected_tools, selected_extensions = select_tools(persona_id)
    
    if not selected_tools and not selected_extensions:
        print("\n✓ No tools selected. Exiting.")
        return
    
    # Install tools
    if IS_WINDOWS:
        install_windows_tools(selected_tools)
        setup_windows_shell()
    elif IS_MACOS:
        install_macos_tools(selected_tools)
        setup_macos_shell()
    
    # Install VS Code extensions
    if selected_extensions:
        install_vscode_extensions(selected_extensions)
    
    # Install Copilot CLI
    install_copilot_cli()
    
    print_header("Installation Complete!")
    print("✅ All selected tools have been installed.")
    print("⚠️  You may need to restart your terminal for PATH changes to take effect.\n")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\n❌ Installation cancelled by user.")
        sys.exit(1)
    except Exception as e:
        print(f"\n\n❌ An error occurred: {e}")
        sys.exit(1)
