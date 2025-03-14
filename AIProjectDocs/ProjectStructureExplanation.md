# Project Structure Explanation

This document provides a clear explanation of the nodes, scenes, and scripts in the current state of the game project.

## Table of Contents
1. [Overview](#overview)
2. [Scene Structure](#scene-structure)
3. [Scripts](#scripts)
4. [Node Relationships](#node-relationships)
5. [Game Flow](#game-flow)

## Overview

This is a 2D platformer game built with Godot Engine. The game features a player character that can move, jump, and collect items while navigating through levels. The project is structured with a main scene that manages the overall game flow, level scenes that define the playable areas, and various scripts that control game logic.

## Scene Structure

### Main Scene (`scenes/main.tscn`)
The main scene serves as the entry point for the game and contains:
- **Main Node (Node2D)**: The root node with the main.gd script attached
- **LevelContainer (Node2D)**: A container for the current level
- **UI (CanvasLayer)**: Contains UI elements including:
  - **HealthBar (ProgressBar)**: Displays player health
  - **ScoreLabel (Label)**: Shows the current score
  - **PauseMenu (Panel)**: Menu displayed when game is paused
  - **GameOverPanel (Panel)**: Shown when the player dies

### Player Scene (`scenes/characters/player.tscn`)
The player character scene contains:
- **Player (CharacterBody2D)**: The root node with player_controller.gd script attached
- **PlayerVisual (Node2D)**: Contains the visual representation of the player
  - **Body (ColorRect)**: Blue rectangle representing the player's body
  - **Head (ColorRect)**: Blue rectangle representing the player's head
  - **Eyes (ColorRect)**: White rectangle for the eyes
  - **LeftPupil/RightPupil (ColorRect)**: Black rectangles for pupils
- **CollisionShape2D**: Defines the player's collision area
- **AnimationPlayer**: Controls player animations (idle, run, jump)

### Level 1 Scene (`scenes/levels/level_1.tscn`)
The first level scene contains:
- **Level1 (Node2D)**: The root node with level_base.gd script attached
- **PlayerSpawn (Marker2D)**: Defines where the player spawns
- **Collectibles (Node2D)**: Container for collectible items
- **Ground (StaticBody2D)**: The main ground platform
- **Platforms (Node2D)**: Container for multiple platforms
  - **Platform1-4 (StaticBody2D)**: Individual jump platforms
- **Exit (Area2D)**: The level exit that triggers level completion

## Scripts

### Main Script (`scripts/main.gd`)
- **Purpose**: Entry point for the game, handles scene management and game state
- **Key Functions**:
  - Loading and switching between levels
  - Spawning the player
  - Managing game pause state
  - Handling player health and death
  - Tracking score

### Player Controller (`scripts/classes/player_controller.gd`)
- **Purpose**: Controls player movement and physics interactions
- **Key Functions**:
  - Handling player input for movement and jumping
  - Managing player health and damage
  - Controlling player animations
  - Implementing invulnerability after taking damage

### Level Base (`scripts/levels/level_base.gd`)
- **Purpose**: Base script for all game levels
- **Key Functions**:
  - Managing level completion
  - Tracking collectibles
  - Handling level exit
  - Implementing time limits (if set)
  - Restarting the current level

### Collectible (`scripts/classes/collectible.gd`)
- **Purpose**: Base script for all collectible items
- **Key Functions**:
  - Handling collection when player touches the item
  - Managing respawn functionality
  - Tracking point values
  - Playing collection animations and sounds

### Game Manager (`scripts/autoload/game_manager.gd`)
- **Purpose**: Global singleton for managing game state
- **Key Functions**:
  - Tracking global score and player lives
  - Managing game pause state
  - Saving and loading game settings
  - Resetting the game

### Audio Manager (`scripts/autoload/audio_manager.gd`)
- **Purpose**: Global singleton for managing game audio
- **Key Functions**:
  - Playing and stopping music tracks with fade effects
  - Playing sound effects
  - Managing audio volume
  - Preloading audio resources

### Main UI (`scripts/ui/main_ui.gd`)
- **Purpose**: Handles the main game UI elements
- **Key Functions**:
  - Updating health bar and score display
  - Showing/hiding pause menu and game over screen
  - Emitting signals for UI button presses

## Node Relationships

1. **Main Scene → Level**: The main scene loads and instantiates the current level as a child of the LevelContainer node.

2. **Main Scene → Player**: The main scene instantiates the player and adds it as a child of the current level.

3. **Player → Main Scene**: The player emits signals (health_changed, player_died) that the main scene listens to.

4. **Level → Main Scene**: Levels emit signals (level_completed, collectible_collected) that the main scene responds to.

5. **Collectibles → Level**: Collectibles emit a "collected" signal that the level listens to.

6. **UI → Main Scene**: UI elements emit signals (resume_pressed, restart_pressed, quit_pressed) that the main scene handles.

7. **Game Manager → Global State**: As an autoload singleton, the Game Manager maintains global game state accessible by all scripts.

8. **Audio Manager → Sound System**: As an autoload singleton, the Audio Manager controls all game audio.

## Game Flow

1. **Game Start**:
   - The main scene loads the initial level (Level 1)
   - The player is spawned at the level's PlayerSpawn position
   - UI elements are initialized

2. **Gameplay**:
   - Player moves and jumps through the level
   - Player can collect items that increase score
   - Health bar shows current player health

3. **Level Completion**:
   - Player reaches the Exit node
   - Level emits level_completed signal
   - Main scene loads the next level (if available)

4. **Player Death**:
   - Player health reaches zero
   - Player emits player_died signal
   - Game over screen is displayed
   - Player can restart or quit

5. **Pause System**:
   - Player presses ESC key
   - Game is paused and pause menu is shown
   - Player can resume, restart, or quit

The game uses a signal-based communication system between nodes, allowing for modular and decoupled code. The autoload singletons (GameManager and AudioManager) provide global access to game state and audio functionality.