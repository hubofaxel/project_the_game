# Collectible
# Base script for all collectible items
class_name Collectible
extends Area2D

# Signals
signal collected

# Exported variables
@export var points: int = 10
@export var auto_collect: bool = true  # If true, collects on body_entered
@export var respawn_time: float = 0.0  # 0 means no respawn

# Public variables
var is_collected: bool = false

# Private variables
var _respawn_timer: float = 0.0
var _initial_position: Vector2
var _initial_modulate: Color

# Onready variables
@onready var _sprite = $Sprite2D
@onready var _collision_shape = $CollisionShape2D
@onready var _animation_player = $AnimationPlayer
@onready var _audio_player = $AudioStreamPlayer2D

# Built-in virtual methods
func _ready() -> void:
	# Check for required nodes
	if not has_node("Sprite2D"):
		push_warning("Collectible missing Sprite2D node")
	
	if not has_node("CollisionShape2D"):
		push_error("Collectible missing CollisionShape2D node")
	
	# Store initial state
	_initial_position = global_position
	if _sprite:
		_initial_modulate = _sprite.modulate
	else:
		_initial_modulate = Color(1, 1, 1, 1)  # Default white if no sprite
	
	# Connect signals
	if has_signal("body_entered"):
		body_entered.connect(_on_body_entered)
	else:
		push_error("Collectible missing body_entered signal")
	
	# Make sure it's not collected at start
	is_collected = false

func _process(delta: float) -> void:
	# Handle respawn timer if item is collected and respawn is enabled
	if is_collected and respawn_time > 0:
		_respawn_timer -= delta
		
		if _respawn_timer <= 0:
			reset()

# Public methods
func collect() -> void:
	"""
	Collect this item if not already collected
	"""
	if is_collected:
		return
	
	is_collected = true
	
	# Play collection animation/sound if available
	if _animation_player and _animation_player.has_animation("collect"):
		_animation_player.play("collect")
	
	if _audio_player and _audio_player.stream:
		_audio_player.play()
	
	# Disable collision
	if _collision_shape:
		_collision_shape.set_deferred("disabled", true)
	
	# Hide sprite (with optional fade out)
	if _sprite:
		if _animation_player and _animation_player.has_animation("collect"):
			# Animation will handle visibility
			pass
		else:
			# Simple disappear
			_sprite.visible = false
	
	# Start respawn timer if enabled
	if respawn_time > 0:
		_respawn_timer = respawn_time
	
	# Emit collected signal
	collected.emit()

func reset() -> void:
	"""
	Reset the collectible to its initial state
	"""
	is_collected = false
	
	# Reset position if it was moved
	global_position = _initial_position
	
	# Enable collision
	if _collision_shape:
		_collision_shape.set_deferred("disabled", false)
	
	# Show sprite
	if _sprite:
		_sprite.visible = true
		_sprite.modulate = _initial_modulate
	
	# Reset animation
	if _animation_player:
		_animation_player.stop()
		if _animation_player.has_animation("idle"):
			_animation_player.play("idle")

func get_points() -> int:
	"""
	Get the point value of this collectible
	"""
	return points

# Private methods
func _play_idle_animation() -> void:
	"""
	Play the idle animation if available
	"""
	if _animation_player and _animation_player.has_animation("idle"):
		_animation_player.play("idle")

# Signal handlers
func _on_body_entered(body: Node2D) -> void:
	"""
	Handle something entering this collectible
	"""
	if not auto_collect:
		return
	
	if is_collected:
		return
	
	# Check if it's the player
	if body.is_in_group("player"):
		collect()