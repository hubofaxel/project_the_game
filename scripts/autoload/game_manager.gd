# Game Manager
# Global singleton for managing game state
extends Node

# Signals
signal game_paused(is_paused)
signal game_reset
signal settings_changed

# Constants
const SAVE_FILE_PATH = "user://save_data.json"

# Public variables
var current_level: int = 1
var total_score: int = 0
var player_lives: int = 3
var settings: Dictionary = {
	"music_volume": 0.8,
	"sfx_volume": 1.0,
	"fullscreen": false,
	"vsync": true
}

# Private variables
var _is_paused: bool = false
var _is_game_over: bool = false

# Built-in virtual methods
func _ready() -> void:
	# Load saved settings
	_load_settings()

func _notification(what: int) -> void:
	# Save settings when the game is about to close
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_settings()

# Public methods
func pause_game(pause: bool) -> void:
	"""
	Pause or unpause the game
	"""
	_is_paused = pause
	get_tree().paused = _is_paused
	game_paused.emit(_is_paused)

func toggle_pause() -> void:
	"""
	Toggle the game pause state
	"""
	pause_game(!_is_paused)

func is_paused() -> bool:
	"""
	Check if the game is paused
	"""
	return _is_paused

func reset_game() -> void:
	"""
	Reset the game state
	"""
	current_level = 1
	total_score = 0
	player_lives = 3
	_is_game_over = false
	
	if _is_paused:
		pause_game(false)
	
	game_reset.emit()

func add_score(points: int) -> void:
	"""
	Add points to the total score
	"""
	total_score += points

func lose_life() -> bool:
	"""
	Reduce player lives by 1
	Returns true if player still has lives, false if game over
	"""
	player_lives -= 1
	
	if player_lives <= 0:
		_is_game_over = true
		return false
	
	return true

func update_setting(key: String, value) -> void:
	"""
	Update a game setting
	"""
	if settings.has(key) and settings[key] != value:
		settings[key] = value
		settings_changed.emit()
		_apply_settings()

# Private methods
func _save_settings() -> void:
	"""
	Save settings to a file
	"""
	var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.WRITE)
	if save_file:
		save_file.store_string(JSON.stringify(settings))

func _load_settings() -> void:
	"""
	Load settings from a file
	"""
	if FileAccess.file_exists(SAVE_FILE_PATH):
		var save_file = FileAccess.open(SAVE_FILE_PATH, FileAccess.READ)
		if save_file:
			var json_string = save_file.get_as_text()
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			
			if parse_result == OK:
				var loaded_settings = json.get_data()
				
				# Update settings with loaded values
				for key in loaded_settings:
					if settings.has(key):
						settings[key] = loaded_settings[key]
				
				# Apply loaded settings
				_apply_settings()

func _apply_settings() -> void:
	"""
	Apply current settings to the game
	"""
	# Apply fullscreen setting
	if OS.has_feature("pc"):
		DisplayServer.window_set_mode(
			DisplayServer.WINDOW_MODE_FULLSCREEN if settings.fullscreen 
			else DisplayServer.WINDOW_MODE_WINDOWED
		)
	
	# Apply vsync setting
	DisplayServer.window_set_vsync_mode(
		DisplayServer.VSYNC_ENABLED if settings.vsync 
		else DisplayServer.VSYNC_DISABLED
	)
	
	# Audio volumes will be handled by AudioManager