# Player Controller
# Handles player movement and physics interactions
class_name PlayerController
extends CharacterBody2D

# Signals
signal health_changed(new_health)
signal player_died

# Constants
const SPEED = 300.0
const JUMP_VELOCITY = -400.0
const MAX_HEALTH = 100

# Exported variables
@export var acceleration = 0.25
@export var friction = 0.1
@export var air_friction = 0.05

# Public variables
var health: int = MAX_HEALTH
var is_invulnerable: bool = false

# Private variables
var _gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var _input_vector = Vector2.ZERO
var _invulnerability_timer: float = 0.0

# Onready variables
@onready var _sprite = $Sprite2D
@onready var _animation_player = $AnimationPlayer
@onready var _collision_shape = $CollisionShape2D

# Built-in virtual methods
func _ready() -> void:
	# Initialize the player
	_sprite.modulate = Color(1, 1, 1, 1)
	health_changed.emit(health)

func _physics_process(delta: float) -> void:
	# Apply gravity
	if not is_on_floor():
		velocity.y += _gravity * delta
	
	# Handle jump
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		_play_animation("jump")
	
	# Get input direction
	_input_vector.x = Input.get_axis("ui_left", "ui_right")
	
	# Handle horizontal movement
	if _input_vector.x != 0:
		velocity.x = lerp(velocity.x, _input_vector.x * SPEED, acceleration)
		_flip_sprite(_input_vector.x)
		
		if is_on_floor():
			_play_animation("run")
	else:
		# Apply friction
		var friction_to_apply = friction if is_on_floor() else air_friction
		velocity.x = lerp(velocity.x, 0.0, friction_to_apply)
		
		if is_on_floor():
			_play_animation("idle")
	
	# Handle invulnerability timer
	if is_invulnerable:
		_invulnerability_timer -= delta
		if _invulnerability_timer <= 0:
			_end_invulnerability()
	
	# Move the character
	move_and_slide()

# Public methods
func take_damage(amount: int) -> void:
	"""
	Reduce player health by the specified amount
	"""
	if is_invulnerable:
		return
	
	health = max(0, health - amount)
	health_changed.emit(health)
	
	if health <= 0:
		_die()
	else:
		_start_invulnerability(1.0)
		_play_animation("hurt")

func heal(amount: int) -> void:
	"""
	Increase player health by the specified amount
	"""
	health = min(MAX_HEALTH, health + amount)
	health_changed.emit(health)
	_play_animation("heal")

# Private methods
func _flip_sprite(direction: float) -> void:
	"""
	Flip the sprite based on movement direction
	"""
	if direction < 0:
		_sprite.flip_h = true
	else:
		_sprite.flip_h = false

func _play_animation(anim_name: String) -> void:
	"""
	Play the specified animation if it's not already playing
	"""
	if _animation_player.has_animation(anim_name) and _animation_player.current_animation != anim_name:
		_animation_player.play(anim_name)

func _start_invulnerability(duration: float) -> void:
	"""
	Make the player invulnerable for the specified duration
	"""
	is_invulnerable = true
	_invulnerability_timer = duration
	# Visual feedback for invulnerability
	_sprite.modulate = Color(1, 1, 1, 0.5)

func _end_invulnerability() -> void:
	"""
	End the player's invulnerability state
	"""
	is_invulnerable = false
	_invulnerability_timer = 0.0
	_sprite.modulate = Color(1, 1, 1, 1)

func _die() -> void:
	"""
	Handle player death
	"""
	_play_animation("die")
	player_died.emit()
	# Disable player input
	set_physics_process(false)
	# You might want to add a respawn mechanism or game over logic here