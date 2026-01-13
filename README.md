# Wave Conqueror

**Wave Conqueror** is a 2D wave defender game built with **Godot 4.5+**. Control a knight, command defenses, and hold the line against endless legions of enemies.

## 🚀 Features

- **Lane-Based Combat**: Fast-paced 4-directional movement responding to vertical threats.
- **Progression**: Level up your Knight, upgrade your Horse, and fortify your Walls.
- **Cross-Platform**: Designed for PC, Console, and Mobile (Touch support included).
- **Economy**: Strategic gold management—repair walls or buy legendary gear?

## 🛠️ How to Run & Develop

We provide PowerShell scripts for a smooth workflow.

### 1. Environment Setup (REQUIRED)

Set the `GODOT_PATH` environment variable to your Godot executable:

```powershell
$env:GODOT_PATH = "C:\Path\To\Godot_v4.5.1_win64.exe"
```

_(Add this to your PowerShell profile for permanence)_

### 2. Available Commands

| Action          | Command           | Description                                |
| :-------------- | :---------------- | :----------------------------------------- |
| **Play Game**   | `./play.ps1`      | Launches the game immediately.             |
| **Open Editor** | `./edit.ps1`      | Opens the project in Godot Editor.         |
| **Debug Mode**  | `./debug.ps1`     | Runs with visible collisions & navigation. |
| **Run Tests**   | `./run_tests.ps1` | Executes all Unit Tests.                   |
| **Build**       | `./build.ps1`     | Exports for Windows (Requires Preset).     |

## 📂 Documentation

- [Game Design Document](docs/game_design.md): Mechanics, Items, Enemies.
- [Implementation Plan](docs/implementation_plan.md): Technical roadmap.
- [Directives](docs/directives.md): Project rules and standards.
- [Tasks](docs/task.md): Current progress checklist.

## 🤝 Contributing

1.  Read the **Directives** in `docs/directives.md`.
2.  Ensure all new features have a corresponding Unit Test.
3.  Verify functionality with `./run_tests.ps1` before committing.
