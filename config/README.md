# Configuration Files

This directory contains JSON configuration files that define the personas, tools, and VS Code extensions available in the setup script.

## Files

### `personas.json`
Defines developer personas (pre-configured toolsets). Each persona includes:
- `label`: Display name
- `description`: Short description
- `tools`: Array of tool IDs (from tools.json)
- `extensions`: Array of VS Code extension IDs (from extensions.json)

**Example:**
```json
{
  "custom-persona": {
    "label": "My Custom Persona",
    "description": "Custom tools for my workflow",
    "tools": ["Git.Git", "Docker.DockerDesktop"],
    "extensions": ["GitHub.copilot", "ms-azuretools.vscode-docker"]
  }
}
```

### `tools.json`
Defines available tools organized by category. Each tool includes:
- `label`: Display name
- `mac_pkg`: Homebrew package name (macOS) or npm package name for npm-based tools
- `type`: "formula", "cask" for Homebrew, or "npm" for npm global packages
- `linux_pkg`: apt package name(s) for Linux or npm package name for npm-based tools
- `linux_snap`: Set to `true` if available via snap
- `linux_source`: Repository name if custom repo needed (e.g., "microsoft", "hashicorp")
- `npm_global`: Set to `true` for npm packages that should be installed globally

**Example:**
```json
{
  "Custom Category": {
    "Vendor.ToolName": {
      "label": "My Custom Tool",
      "mac_pkg": "custom-tool",
      "type": "formula",
      "linux_pkg": "custom-tool",
      "linux_snap": false
    },
    "My.NPMTool": {
      "label": "My NPM Tool",
      "mac_pkg": "@scope/package-name",
      "type": "npm",
      "linux_pkg": "@scope/package-name",
      "npm_global": true
    }
  }
}
```

**Windows Note:** Tool IDs are used directly with winget on Windows, except for npm packages which use npm globally.

### `extensions.json`
Maps VS Code extension IDs to display names.

**Example:**
```json
{
  "publisher.extension-id": "Display Name"
}
```

## Customization

To customize the setup script:

1. **Add a new persona:**
   - Edit `personas.json`
   - Add a new entry with tool and extension IDs
   - Tool IDs must exist in `tools.json`
   - Extension IDs must exist in `extensions.json`

2. **Add a new tool:**
   - Edit `tools.json`
   - Add under appropriate category
   - Provide package names for each platform
   - For Linux: If tool requires custom repository (Microsoft, HashiCorp, etc.), set `linux_source`

3. **Add a new VS Code extension:**
   - Edit `extensions.json`
   - Add extension ID and display name

## Validation

The setup script will:
- Load configurations from JSON files
- Fall back to default configurations if files are missing
- Display warnings if JSON parsing fails
- Continue with default values on error

## Example: Creating a "Go Developer" Persona

1. Ensure tools exist in `tools.json`:
```json
{
  "Programming Languages": {
    "GoLang.Go": {
      "label": "Go",
      "mac_pkg": "go",
      "type": "formula",
      "linux_pkg": "golang-go"
    }
  }
}
```

2. Add persona to `personas.json`:
```json
{
  "go-developer": {
    "label": "Go Developer",
    "description": "Go programming with Docker and GitHub tools",
    "tools": [
      "Git.Git",
      "GoLang.Go",
      "Microsoft.VisualStudioCode",
      "Docker.DockerDesktop",
      "GitHub.cli"
    ],
    "extensions": [
      "GitHub.copilot",
      "GitHub.copilot-chat",
      "golang.go",
      "ms-azuretools.vscode-docker"
    ]
  }
}
```

3. Run the setup script - your new persona will appear in the menu!
