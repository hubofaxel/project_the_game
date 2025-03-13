# GDScript Coding Standards

## Official Documentation Reference
Based on [Godot 4.x Documentation - GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html)

## Naming Conventions

### Files
- Use snake_case for file names: `player_controller.gd`, `main_menu.tscn`

### Classes (via `class_name`)
- Use PascalCase: `PlayerController`, `EnemySpawner`

### Functions and Variables
- Use snake_case: `func move_player():`, `var player_health = 100`
- Constants should use ALL_CAPS: `const MAX_SPEED = 500`
- Signals should use snake_case: `signal health_depleted`

### Private Functions and Variables
- Prefix with underscore: `func _private_function():`, `var _internal_state = 0`

## Code Structure

### Script Structure
```gdscript
# Meta information comment (author, description, etc.)
class_name MyClass
extends Node

# Signals
signal health_changed(new_health)

# Enums
enum {IDLE, RUNNING, JUMPING}

# Constants
const MAX_SPEED = 500

# Exported variables
@export var health: int = 100

# Public variables
var velocity: Vector2 = Vector2.ZERO

# Private variables
var _private_var: bool = false

# Onready variables
@onready var sprite = $Sprite2D

# Built-in virtual methods
func _ready():
    pass

func _process(delta):
    pass

# Public methods
func take_damage(amount: int) -> void:
    health -= amount
    health_changed.emit(health)

# Private methods
func _handle_movement() -> void:
    pass
```

## Best Practices

1. **Type Hints**: Use type hints for function parameters and return values
   ```gdscript
   func calculate_damage(base_damage: int, multiplier: float) -> int:
       return int(base_damage * multiplier)
   ```

2. **Comments**: Use comments to explain why, not what
   ```gdscript
   # Increase speed when player has the speed powerup
   if has_powerup:
       speed *= 1.5
   ```

3. **Signal Connections**: Prefer connecting signals in code rather than in the editor for better tracking
   ```gdscript
   func _ready():
       button.pressed.connect(_on_button_pressed)
   ```

4. **Node References**: Use `@onready` for node references
   ```gdscript
   @onready var animation_player = $AnimationPlayer
   ```

5. **Error Handling**: Check for null or invalid values
   ```gdscript
   if target != null and is_instance_valid(target):
       # Do something with target
   ```

## Version Information
- Documentation based on Godot 4.x