#!/usr/bin/env python3
"""
Unit tests for setup-dev-env.py
Tests cover utility functions, configuration validation, and core logic.
"""

import pytest
import subprocess
import sys
import platform
from pathlib import Path
from unittest.mock import Mock, patch, MagicMock, call
import importlib.util

# Import the module to test
spec = importlib.util.spec_from_file_location("setup_dev_env", "setup-dev-env.py")
setup_dev_env = importlib.util.module_from_spec(spec)
sys.modules["setup_dev_env"] = setup_dev_env
spec.loader.exec_module(setup_dev_env)


class TestPrintHeader:
    """Test the print_header function"""
    
    def test_print_header(self, capsys):
        """Test that print_header outputs formatted text"""
        setup_dev_env.print_header("Test Header")
        captured = capsys.readouterr()
        assert "Test Header" in captured.out
        assert "=" * 60 in captured.out


class TestCheckCommandExists:
    """Test the check_command_exists function"""
    
    def test_command_exists(self):
        """Test that check_command_exists returns True for valid commands"""
        # Python should exist in the test environment
        assert setup_dev_env.check_command_exists(sys.executable) is True
    
    def test_command_not_exists(self):
        """Test that check_command_exists returns False for invalid commands"""
        assert setup_dev_env.check_command_exists("nonexistent_command_xyz123") is False


class TestRunCommand:
    """Test the run_command function"""
    
    def test_run_command_success(self):
        """Test run_command with a successful command"""
        if platform.system() == "Windows":
            success, stdout, stderr = setup_dev_env.run_command(["cmd", "/c", "echo", "test"])
        else:
            success, stdout, stderr = setup_dev_env.run_command(["echo", "test"])
        
        assert success is True
        assert "test" in stdout
    
    def test_run_command_failure(self):
        """Test run_command with a failing command"""
        success, stdout, stderr = setup_dev_env.run_command(
            ["python", "-c", "import sys; sys.exit(1)"],
            check=False
        )
        assert success is False
    
    def test_run_command_with_shell(self):
        """Test run_command with shell=True"""
        if platform.system() == "Windows":
            success, stdout, stderr = setup_dev_env.run_command("echo test", shell=True)
        else:
            success, stdout, stderr = setup_dev_env.run_command("echo test", shell=True)
        
        assert success is True
        assert "test" in stdout


class TestPersonasConfiguration:
    """Test the PERSONAS configuration"""
    
    def test_personas_exist(self):
        """Test that personas are defined"""
        assert len(setup_dev_env.PERSONAS) > 0
    
    def test_persona_structure(self):
        """Test that each persona has required fields"""
        for persona_id, persona_info in setup_dev_env.PERSONAS.items():
            assert "label" in persona_info
            assert "description" in persona_info
            assert "tools" in persona_info
            assert "extensions" in persona_info
            assert isinstance(persona_info["tools"], list)
            assert isinstance(persona_info["extensions"], list)
    
    def test_dotnet_persona(self):
        """Test .NET persona configuration"""
        dotnet = setup_dev_env.PERSONAS["dotnet-fullstack"]
        assert "Git.Git" in dotnet["tools"]
        assert "Microsoft.DotNet.SDK.9" in dotnet["tools"]
        assert "GitHub.copilot" in dotnet["extensions"]
    
    def test_nodejs_persona(self):
        """Test Node.js persona configuration"""
        nodejs = setup_dev_env.PERSONAS["nodejs-fullstack"]
        assert "OpenJS.NodeJS.LTS" in nodejs["tools"]
        assert "Docker.DockerDesktop" in nodejs["tools"]
    
    def test_python_persona(self):
        """Test Python persona configuration"""
        python = setup_dev_env.PERSONAS["python-fullstack"]
        assert "Python.Python.3.12" in python["tools"]
        assert "ms-python.python" in python["extensions"]
    
    def test_java_persona(self):
        """Test Java persona configuration"""
        java = setup_dev_env.PERSONAS["java-fullstack"]
        assert "EclipseAdoptium.Temurin.21" in java["tools"]
        assert "Apache.Maven" in java["tools"]
    
    def test_custom_persona(self):
        """Test custom persona configuration"""
        custom = setup_dev_env.PERSONAS["custom"]
        assert custom["tools"] == []
        assert custom["extensions"] == []


class TestToolConfiguration:
    """Test the TOOL_CONFIG configuration"""
    
    def test_tool_config_exists(self):
        """Test that tool configuration is defined"""
        assert len(setup_dev_env.TOOL_CONFIG) > 0
    
    def test_tool_categories(self):
        """Test that expected tool categories exist"""
        expected_categories = [
            "Core", 
            "API & Testing", 
            "Cloud & Infrastructure",
            "Containers & Databases",
            "Programming Languages",
            "Build Tools",
            "Productivity"
        ]
        for category in expected_categories:
            assert category in setup_dev_env.TOOL_CONFIG
    
    def test_tool_structure(self):
        """Test that each tool has required fields"""
        for category, tools in setup_dev_env.TOOL_CONFIG.items():
            for tool_id, tool_info in tools.items():
                assert "label" in tool_info
                # Either mac_pkg or windows-only type should be present
                assert "mac_pkg" in tool_info or tool_info.get("type") == "windows-only"
    
    def test_git_tool(self):
        """Test Git tool configuration"""
        git = setup_dev_env.TOOL_CONFIG["Core"]["Git.Git"]
        assert git["label"] == "Git"
        assert git["mac_pkg"] == "git"
    
    def test_vscode_tool(self):
        """Test VS Code tool configuration"""
        vscode = setup_dev_env.TOOL_CONFIG["Core"]["Microsoft.VisualStudioCode"]
        assert "Visual Studio Code" in vscode["label"]
        assert vscode["type"] == "cask"


class TestVSCodeExtensions:
    """Test the VSCODE_EXTENSIONS configuration"""
    
    def test_vscode_extensions_exist(self):
        """Test that VS Code extensions are defined"""
        assert len(setup_dev_env.VSCODE_EXTENSIONS) > 0
    
    def test_copilot_extensions(self):
        """Test that Copilot extensions are present"""
        assert "GitHub.copilot" in setup_dev_env.VSCODE_EXTENSIONS
        assert "GitHub.copilot-chat" in setup_dev_env.VSCODE_EXTENSIONS
    
    def test_extension_structure(self):
        """Test that each extension has a label"""
        for ext_id, ext_label in setup_dev_env.VSCODE_EXTENSIONS.items():
            assert isinstance(ext_label, str)
            assert len(ext_label) > 0


class TestSelectPersona:
    """Test the select_persona function"""
    
    @patch('setup_dev_env.questionary.select')
    def test_select_persona_success(self, mock_select):
        """Test successful persona selection"""
        mock_select.return_value.ask.return_value = "dotnet-fullstack"
        result = setup_dev_env.select_persona()
        assert result == "dotnet-fullstack"
        mock_select.assert_called_once()
    
    @patch('setup_dev_env.questionary.select')
    @patch('sys.exit')
    def test_select_persona_cancelled(self, mock_exit, mock_select):
        """Test cancelled persona selection"""
        mock_select.return_value.ask.return_value = None
        setup_dev_env.select_persona()
        mock_exit.assert_called_once_with(0)


class TestSelectTools:
    """Test the select_tools function"""
    
    @patch('setup_dev_env.questionary.checkbox')
    def test_select_tools_with_persona(self, mock_checkbox):
        """Test tool selection with a persona"""
        mock_checkbox.return_value.ask.return_value = [
            ("tool", "Core", "Git.Git"),
            ("extension", "GitHub.copilot")
        ]
        
        selected_tools, selected_extensions = setup_dev_env.select_tools("dotnet-fullstack")
        
        assert "Core" in selected_tools
        assert "Git.Git" in selected_tools["Core"]
        assert "GitHub.copilot" in selected_extensions
        mock_checkbox.assert_called_once()
    
    @patch('setup_dev_env.questionary.checkbox')
    def test_select_tools_custom(self, mock_checkbox):
        """Test tool selection with custom persona"""
        mock_checkbox.return_value.ask.return_value = [
            ("tool", "Core", "Git.Git")
        ]
        
        selected_tools, selected_extensions = setup_dev_env.select_tools("custom")
        
        assert "Core" in selected_tools
        mock_checkbox.assert_called_once()
    
    @patch('setup_dev_env.questionary.checkbox')
    def test_select_tools_cancelled(self, mock_checkbox):
        """Test cancelled tool selection"""
        mock_checkbox.return_value.ask.return_value = None
        
        # This should raise SystemExit due to sys.exit(0)
        with pytest.raises(SystemExit) as excinfo:
            setup_dev_env.select_tools()
        
        assert excinfo.value.code == 0


class TestConfirmSelection:
    """Test the confirm_selection function"""
    
    @patch('setup_dev_env.questionary.select')
    def test_confirm_install(self, mock_select):
        """Test confirmation to install"""
        mock_select.return_value.ask.return_value = "install"
        result = setup_dev_env.confirm_selection(
            "dotnet-fullstack",
            {"Core": ["Git.Git"]},
            ["GitHub.copilot"]
        )
        assert result == "install"
    
    @patch('setup_dev_env.questionary.select')
    def test_confirm_cancel(self, mock_select):
        """Test cancellation"""
        mock_select.return_value.ask.return_value = "cancel"
        result = setup_dev_env.confirm_selection(
            "dotnet-fullstack",
            {"Core": ["Git.Git"]},
            ["GitHub.copilot"]
        )
        assert result == "cancel"
    
    @patch('setup_dev_env.questionary.select')
    def test_confirm_back_to_tools(self, mock_select):
        """Test going back to tool selection"""
        mock_select.return_value.ask.return_value = "tools"
        result = setup_dev_env.confirm_selection(
            "dotnet-fullstack",
            {"Core": ["Git.Git"]},
            ["GitHub.copilot"]
        )
        assert result == "tools"


class TestInstallWindowsTools:
    """Test the install_windows_tools function"""
    
    @patch('setup_dev_env.check_command_exists')
    @patch('setup_dev_env.run_command')
    def test_install_windows_tools_winget_not_found(self, mock_run, mock_check):
        """Test Windows installation when winget is not found"""
        mock_check.return_value = False
        
        selected_tools = {"Core": ["Git.Git"]}
        setup_dev_env.install_windows_tools(selected_tools)
        
        # Should not attempt to run winget commands
        assert mock_run.call_count == 0
    
    @patch('setup_dev_env.check_command_exists')
    @patch('setup_dev_env.run_command')
    def test_install_windows_tools_already_installed(self, mock_run, mock_check):
        """Test Windows installation when tool is already installed"""
        mock_check.return_value = True
        mock_run.return_value = (True, "Git.Git", "")
        
        selected_tools = {"Core": ["Git.Git"]}
        setup_dev_env.install_windows_tools(selected_tools)
        
        # Should check if installed
        assert mock_run.call_count > 0
    
    @patch('setup_dev_env.check_command_exists')
    @patch('setup_dev_env.run_command')
    def test_install_windows_tools_new_install(self, mock_run, mock_check):
        """Test Windows installation of new tool"""
        mock_check.return_value = True
        # First call checks if installed (not found), second call installs
        mock_run.side_effect = [
            (True, "", ""),  # Check - not installed
            (True, "", "")   # Install
        ]
        
        selected_tools = {"Core": ["Git.Git"]}
        setup_dev_env.install_windows_tools(selected_tools)
        
        assert mock_run.call_count == 2


class TestInstallMacOSTools:
    """Test the install_macos_tools function"""
    
    @patch('setup_dev_env.check_command_exists')
    @patch('setup_dev_env.run_command')
    def test_install_macos_tools_brew_exists(self, mock_run, mock_check):
        """Test macOS installation when Homebrew exists"""
        mock_check.return_value = True
        mock_run.return_value = (True, "", "")
        
        selected_tools = {"Core": ["Git.Git"]}
        setup_dev_env.install_macos_tools(selected_tools)
        
        # Should use brew commands
        assert mock_run.call_count > 0
    
    @patch('setup_dev_env.check_command_exists')
    @patch('setup_dev_env.run_command')
    def test_install_macos_tools_cask(self, mock_run, mock_check):
        """Test macOS installation of cask package"""
        mock_check.return_value = True
        # First call checks if installed (not found), second call installs
        mock_run.side_effect = [
            (False, "", ""),  # Check - not installed
            (True, "", "")    # Install
        ]
        
        selected_tools = {"Core": ["Microsoft.VisualStudioCode"]}
        setup_dev_env.install_macos_tools(selected_tools)
        
        assert mock_run.call_count == 2


class TestInstallVSCodeExtensions:
    """Test the install_vscode_extensions function"""
    
    @patch('setup_dev_env.check_command_exists')
    @patch('setup_dev_env.run_command')
    def test_install_vscode_extensions_success(self, mock_run, mock_check):
        """Test successful VS Code extension installation"""
        mock_check.return_value = True
        mock_run.return_value = (True, "", "")
        
        selected_extensions = ["GitHub.copilot", "GitHub.copilot-chat"]
        setup_dev_env.install_vscode_extensions(selected_extensions)
        
        assert mock_run.call_count == 2
    
    @patch('setup_dev_env.check_command_exists')
    def test_install_vscode_extensions_no_code_cli(self, mock_check):
        """Test VS Code extension installation when CLI not found"""
        mock_check.return_value = False
        
        selected_extensions = ["GitHub.copilot"]
        setup_dev_env.install_vscode_extensions(selected_extensions)
        
        # Should exit early without installing


class TestInstallCopilotCLI:
    """Test the install_copilot_cli function"""
    
    @patch('setup_dev_env.check_command_exists')
    @patch('setup_dev_env.run_command')
    def test_install_copilot_cli_node_not_found(self, mock_run, mock_check):
        """Test Copilot CLI installation when Node.js not found"""
        mock_check.return_value = False
        
        setup_dev_env.install_copilot_cli()
        
        # Should not attempt to install
        assert mock_run.call_count == 0
    
    @patch('setup_dev_env.check_command_exists')
    @patch('setup_dev_env.run_command')
    def test_install_copilot_cli_already_installed(self, mock_run, mock_check):
        """Test Copilot CLI when already installed"""
        mock_check.side_effect = [True, True]  # node exists, copilot-cli exists
        
        setup_dev_env.install_copilot_cli()
        
        # Should not attempt to install
        assert mock_run.call_count == 0
    
    @patch('setup_dev_env.check_command_exists')
    @patch('setup_dev_env.run_command')
    def test_install_copilot_cli_new_install(self, mock_run, mock_check):
        """Test new Copilot CLI installation"""
        mock_check.side_effect = [True, False]  # node exists, copilot-cli doesn't
        mock_run.return_value = (True, "", "")
        
        setup_dev_env.install_copilot_cli()
        
        assert mock_run.call_count == 1


class TestShellEnhancements:
    """Test shell enhancement functions"""
    
    @patch('setup_dev_env.check_command_exists')
    @patch('setup_dev_env.run_command')
    @patch('setup_dev_env.Path')
    def test_setup_windows_shell(self, mock_path, mock_run, mock_check):
        """Test Windows shell setup"""
        mock_check.return_value = True
        mock_run.return_value = (True, "", "")
        
        # Mock path operations
        mock_profile = MagicMock()
        mock_profile.exists.return_value = False
        mock_profile.parent.mkdir = MagicMock()
        mock_profile.touch = MagicMock()
        mock_path.home.return_value.joinpath.return_value = mock_profile
        
        setup_dev_env.setup_windows_shell()
        
        # Should attempt to install Oh My Posh and Terminal-Icons
        assert mock_run.call_count >= 1
    
    @patch('setup_dev_env.run_command')
    @patch('setup_dev_env.Path')
    def test_setup_macos_shell(self, mock_path, mock_run):
        """Test macOS shell setup"""
        mock_run.return_value = (True, "", "")
        mock_path.home.return_value.joinpath.return_value.exists.return_value = False
        
        setup_dev_env.setup_macos_shell()
        
        # Should attempt to install Oh My Zsh and fonts
        assert mock_run.call_count >= 1


class TestPlatformDetection:
    """Test platform detection variables"""
    
    def test_platform_variables_exist(self):
        """Test that platform detection variables are set"""
        assert hasattr(setup_dev_env, 'IS_WINDOWS')
        assert hasattr(setup_dev_env, 'IS_MACOS')
        assert isinstance(setup_dev_env.IS_WINDOWS, bool)
        assert isinstance(setup_dev_env.IS_MACOS, bool)
    
    def test_platform_detection(self):
        """Test that exactly one platform is detected (or Linux in test env)"""
        # Either Windows or macOS should be True, or we're on Linux (test environment)
        # In production, the script checks for Windows or macOS only
        current_platform = platform.system()
        if current_platform in ["Windows", "Darwin"]:
            assert setup_dev_env.IS_WINDOWS or setup_dev_env.IS_MACOS
        else:
            # In Linux test environment, both should be False
            assert not setup_dev_env.IS_WINDOWS and not setup_dev_env.IS_MACOS


class TestDataIntegrity:
    """Test data integrity and cross-references"""
    
    def test_persona_tools_exist_in_config(self):
        """Test that all persona tools exist in TOOL_CONFIG"""
        for persona_id, persona_info in setup_dev_env.PERSONAS.items():
            if persona_id == "custom":
                continue
            
            for tool_id in persona_info["tools"]:
                found = False
                for category, tools in setup_dev_env.TOOL_CONFIG.items():
                    if tool_id in tools:
                        found = True
                        break
                
                assert found, f"Tool {tool_id} from persona {persona_id} not found in TOOL_CONFIG"
    
    def test_persona_extensions_exist_in_config(self):
        """Test that all persona extensions exist in VSCODE_EXTENSIONS"""
        for persona_id, persona_info in setup_dev_env.PERSONAS.items():
            if persona_id == "custom":
                continue
            
            for ext_id in persona_info["extensions"]:
                assert ext_id in setup_dev_env.VSCODE_EXTENSIONS, \
                    f"Extension {ext_id} from persona {persona_id} not found in VSCODE_EXTENSIONS"


if __name__ == "__main__":
    pytest.main([__file__, "-v", "--cov=setup_dev_env", "--cov-report=term-missing"])
