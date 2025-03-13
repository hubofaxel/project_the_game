# VS Code Setup for Godot Development

## Official Documentation Reference
Based on [Godot 4.x Documentation](https://docs.godotengine.org/) and [Godot Tools for VS Code](https://marketplace.visualstudio.com/items?itemName=geequlim.godot-tools)

## VS Code Configuration

### Required Extensions
- **Godot Tools** (geequlim.godot-tools): Provides GDScript language support, debugging, and integration with Godot editor
- **GDScript Formatter** (Razoric.gdscript-toolkit-formatter): Optional but recommended for code formatting

### VS Code Settings
The following settings have been configured in `.vscode/settings.json`:

```json
{
    "godot_tools.editor_path": "C:/Users/axelp/Game Engines/Godot_v4.4-stable_win64.exe",
    "godot_tools.gdscript_lsp_server_protocol": "tcp",
    "editor.formatOnSave": true,
    "editor.insertSpaces": true,
    "editor.detectIndentation": false,
    "editor.tabSize": 4
}
```

- **godot_tools.editor_path**: Path to your Godot executable
- **godot_tools.gdscript_lsp_server_protocol**: Protocol for the GDScript Language Server (tcp recommended)
- **editor.formatOnSave**: Automatically format code when saving
- **editor.tabSize**: Set to 4 spaces as per GDScript style guidelines

## Workflow Between VS Code and Godot

### Development Workflow

1. **Project Setup**:
   - Create a new project in Godot Editor
   - Open the project folder in VS Code

2. **Scene Editing**:
   - Use Godot Editor for scene composition, node setup, and visual elements
   - Use VS Code for script editing

3. **Script Editing**:
   - Edit GDScript files in VS Code
   - Benefit from code completion, syntax highlighting, and error checking
   - Use F1 and type "Godot Tools" to access Godot-specific commands

4. **Running the Game**:
   - Press F5 in VS Code to run the current scene in Godot
   - Alternatively, use the Godot Editor to run the game

5. **Switching Between Editors**:
   - In VS Code: Press F1 and select "Godot Tools: Open workspace with Godot editor"
   - In Godot: Click on a script file to open it in VS Code (if configured as external editor)

### Configuring Godot to Use VS Code as External Editor

1. Open Godot Editor
2. Go to Editor → Editor Settings
3. Navigate to Text Editor → External
4. Check "Use External Editor"
5. Set "Exec Path" to your VS Code executable (e.g., `C:/Users/axelp/AppData/Local/Programs/Microsoft VS Code/Code.exe`)
6. Set "Exec Flags" to `{project} --goto {file}:{line}:{col}`

## Debugging

### Setup Debugging in VS Code

1. Create a `.vscode/launch.json` file with the following content:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "GDScript Godot",
            "type": "godot",
            "request": "launch",
            "project": "${workspaceFolder}",
            "port": 6007,
            "address": "127.0.0.1",
            "launch_game_instance": true,
            "launch_scene": false
        }
    ]
}
```

2. Set breakpoints in your GDScript files
3. Press F5 to start debugging

### Debugging Features

- Set breakpoints by clicking in the gutter
- Inspect variables in the Debug panel
- Use the Debug Console to evaluate expressions
- Step through code using the debug controls

## Best Practices

1. **Project Organization**:
   - Follow the project structure outlined in [GodotProjectStructure.md](./GodotProjectStructure.md)
   - Keep scripts organized in a logical folder structure

2. **Code Style**:
   - Follow the GDScript coding standards in [GDScriptCodingStandards.md](./GDScriptCodingStandards.md)
   - Use the GDScript formatter for consistent code style

3. **Version Control**:
   - Use Git for version control
   - Add appropriate `.gitignore` for Godot projects
   - Commit frequently with meaningful messages

4. **Scene vs Script Responsibilities**:
   - Use Godot Editor for scene composition and visual elements
   - Use VS Code for script logic and code organization

5. **Documentation**:
   - Document your code with comments
   - Keep design documents updated as the project evolves

## Keyboard Shortcuts

| Action | VS Code Shortcut | Description |
|--------|-----------------|-------------|
| Run Project | F5 | Run the current project in Godot |
| Open Godot Editor | F1 → "Godot Tools: Open workspace with Godot editor" | Switch to Godot Editor |
| Format Document | Shift+Alt+F | Format the current document |
| Go to Definition | F12 | Navigate to the definition of a symbol |
| Find References | Shift+F12 | Find all references to a symbol |

## Troubleshooting

### Common Issues

1. **GDScript Language Server Not Starting**:
   - Ensure the Godot executable path is correct in settings
   - Try changing the protocol from "tcp" to "ws" in settings
   - Restart VS Code

2. **Code Completion Not Working**:
   - Make sure the Godot project has been opened at least once in the Godot Editor
   - Check if the language server is running (status bar should show "GDScript: Ready")

3. **Debugging Not Connecting**:
   - Verify the port in launch.json matches the debug port in Godot settings
   - Ensure Godot is running when you start debugging

## Version Information
- Documentation based on Godot 4.4 and VS Code Godot Tools extension