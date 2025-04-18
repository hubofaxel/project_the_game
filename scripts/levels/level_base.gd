# Level Base
# Base script for all game levels
extends Node2D

# Signals
signal level_completed
signal collectible_collected(points)

# Exported variables
@export var level_name: String = "Level"
@export var next_level: PackedScene
@export var time_limit: float = 0.0  # 0 means no time limit

# Public variables
var collectibles_total: int = 0
var collectibles_collected: int = 0

# Private variables
var _time_remaining: float
var _level_started: bool = false
var _level_completed: bool = false
var _player_spawn_position: Vector2

# Onready variables
@onready var _collectibles = $Collectibles
@onready var _player_spawn = $PlayerSpawn
@onready var _exit = $Exit

# Built-in virtual methods
func _ready() -> void:
	# Initialize level
	_count_collectibles()
	
	if _player_spawn:
		_player_spawn_position = _player_spawn.global_position
	
	if time_limit > 0:
		_time_remaining = time_limit
	
	# Connect exit signal if exit exists
	if _exit and _exit.has_signal("body_entered"):
		_exit.body_entered.connect(_on_exit_body_entered)
	
	# Connect collectible signals
	_connect_collectible_signals()
	
	_level_started = true

func _process(delta: float) -> void:
	# Handle time limit if set
	if time_limit > 0 and _level_started and not _level_completed:
		_time_remaining -= delta
		
		if _time_remaining <= 0:
			_on_time_expired()

# Public methods
func restart() -> void:
	"""
	Restart the current level
	"""
	# Reset level state
	collectibles_collected = 0
	_level_completed = false
	
	if time_limit > 0:
		_time_remaining = time_limit
	
	# Reset collectibles
	_reset_collectibles()
	
	# Respawn player at spawn point
	var player = get_tree().get_first_node_in_group("player")
	if player and _player_spawn:
		player.global_position = _player_spawn_position

func get_completion_percentage() -> float:
	"""
	Get the level completion percentage based on collectibles
	"""
	if collectibles_total == 0:
		return 100.0
	
	return (float(collectibles_collected) / float(collectibles_total)) * 100.0

# Private methods
func _count_collectibles() -> void:
	"""
	Count the total number of collectibles in the level
	"""
	if _collectibles:
		collectibles_total = _collectibles.get_child_count()

func _connect_collectible_signals() -> void:
	"""
	Connect signals from all collectibles
	"""
	if _collectibles:
		for collectible in _collectibles.get_children():
			if collectible.has_signal("collected"):
				collectible.collected.connect(_on_collectible_collected.bind(collectible))

func _reset_collectibles() -> void:
	"""
	Reset all collectibles to their initial state
	"""
	if _collectibles:
		for collectible in _collectibles.get_children():
			if collectible.has_method("reset"):
				collectible.reset()

func _complete_level() -> void:
	"""
	Mark the level as completed and emit signal
	"""
	if not _level_completed:
		_level_completed = true
		level_completed.emit()
		
		# Load next level if available
		if next_level:
			# Find the main scene using a more robust method
			var main = _find_main_scene()
			if main and main.has_method("load_level"):
				# Add a small delay before loading next level
				await get_tree().create_timer(1.0).timeout
				main.load_level(next_level)
			else:
				push_warning("Could not find main scene with load_level method")

# Helper methods
func _find_main_scene() -> Node:
	"""
	Find the main scene using a more robust method
	"""
	# Try to find a node named "Main" in the scene tree
	var main = get_tree().get_root().get_node_or_null("Main")
	
	# If not found, try to find a node with the load_level method
	if not main:
		var root = get_tree().get_root()
		for i in range(root.get_child_count()):
			var node = root.get_child(i)
			if node.has_method("load_level"):
				main = node
				break
	
	return main

# Signal handlers
func _on_collectible_collected(collectible) -> void:
	"""
	Handle collectible collected signal
	"""
	collectibles_collected += 1
	
	# Emit signal with points value
	var points = 10  # Default value
	if collectible.has_method("get_points"):
		points = collectible.get_points()
	
	collectible_collected.emit(points)
	
	# Check if all collectibles are collected
	if collectibles_collected >= collectibles_total:
		# Maybe trigger something special or just wait for player to reach exit
		pass

func _on_exit_body_entered(body: Node2D) -> void:
	"""
	Handle player entering the level exit
	"""
	if body.is_in_group("player"):
		_complete_level()

func _on_time_expired() -> void:
	"""
	Handle time limit expiration
	"""
	# Get player and trigger damage or game over
	var player = get_tree().get_first_node_in_group("player")
	if player and player.has_method("take_damage"):
		# Kill player when time expires
		player.take_damage(999)
