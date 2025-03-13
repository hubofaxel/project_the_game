# Main Game Scene
# Entry point for the game, handles scene management and game state
extends Node2D

# Constants
const PLAYER_SCENE = preload("res://scenes/characters/player.tscn")

# Exported variables
@export var initial_level: PackedScene

# Public variables
var current_level: Node
var player: PlayerController

# Private variables
var _score: int = 0
var _game_paused: bool = false

# Onready variables
@onready var _ui = $UI
@onready var _pause_menu = $UI/PauseMenu
@onready var _level_container = $LevelContainer

# Built-in virtual methods
func _ready() -> void:
	# Initialize the game
	_pause_menu.visible = false
	_load_initial_level()
	_spawn_player()

func _process(_delta: float) -> void:
	# Handle pause input
	if Input.is_action_just_pressed("ui_cancel"):
		_toggle_pause()

# Public methods
func restart_game() -> void:
	"""
	Restart the current level
	"""
	_score = 0
	_ui.update_score(_score)
	
	# Remove current level
	if current_level != null:
		current_level.queue_free()
	
	# Load initial level
	_load_initial_level()
	_spawn_player()
	
	# Unpause if paused
	if _game_paused:
		_toggle_pause()

func add_score(points: int) -> void:
	"""
	Add points to the player's score
	"""
	_score += points
	_ui.update_score(_score)

func load_level(level_scene: PackedScene) -> void:
	"""
	Load a new level
	"""
	# Remove current level
	if current_level != null:
		current_level.queue_free()
	
	# Instantiate and add the new level
	current_level = level_scene.instantiate()
	_level_container.add_child(current_level)
	
	# Spawn player in the new level
	_spawn_player()

# Private methods
func _load_initial_level() -> void:
	"""
	Load the initial level of the game
	"""
	if initial_level != null:
		current_level = initial_level.instantiate()
		_level_container.add_child(current_level)
	else:
		push_error("No initial level set!")

func _spawn_player() -> void:
	"""
	Spawn the player at the spawn point
	"""
	# Remove existing player if any
	if player != null:
		player.queue_free()
	
	# Find spawn point in current level
	var spawn_point = current_level.get_node_or_null("PlayerSpawn")
	if spawn_point == null:
		push_warning("No PlayerSpawn node found in level, using default position")
	
	# Instantiate player
	player = PLAYER_SCENE.instantiate()
	
	# Set player position
	if spawn_point != null:
		player.global_position = spawn_point.global_position
	
	# Add player to the scene
	current_level.add_child(player)
	
	# Connect player signals
	player.health_changed.connect(_on_player_health_changed)
	player.player_died.connect(_on_player_died)

func _toggle_pause() -> void:
	"""
	Toggle game pause state
	"""
	_game_paused = !_game_paused
	get_tree().paused = _game_paused
	_pause_menu.visible = _game_paused

# Signal handlers
func _on_player_health_changed(new_health: int) -> void:
	"""
	Handle player health changed signal
	"""
	_ui.update_health(new_health)

func _on_player_died() -> void:
	"""
	Handle player death
	"""
	# Show game over screen after a short delay
	await get_tree().create_timer(1.0).timeout
	_ui.show_game_over()

func _on_pause_menu_resume() -> void:
	"""
	Handle resume button pressed in pause menu
	"""
	_toggle_pause()

func _on_pause_menu_quit() -> void:
	"""
	Handle quit button pressed in pause menu
	"""
	get_tree().quit()