# Game UI
# Handles all UI elements and interactions
extends CanvasLayer

# Exported variables
@export var health_bar: ProgressBar
@export var score_label: Label
@export var game_over_panel: Panel
@export var pause_menu: Panel

# Private variables
var _max_health: int = 100

# Built-in virtual methods
func _ready() -> void:
	# Initialize UI elements
	if health_bar:
		health_bar.max_value = _max_health
		health_bar.value = _max_health
	
	if score_label:
		score_label.text = "Score: 0"
	
	if game_over_panel:
		game_over_panel.visible = false
	
	if pause_menu:
		pause_menu.visible = false

# Public methods
func update_health(new_health: int) -> void:
	"""
	Update the health bar with the new health value
	"""
	if health_bar:
		health_bar.value = new_health

func update_score(new_score: int) -> void:
	"""
	Update the score display
	"""
	if score_label:
		score_label.text = "Score: %d" % new_score

func show_game_over() -> void:
	"""
	Display the game over screen
	"""
	if game_over_panel:
		game_over_panel.visible = true

func hide_game_over() -> void:
	"""
	Hide the game over screen
	"""
	if game_over_panel:
		game_over_panel.visible = false

func show_pause_menu() -> void:
	"""
	Display the pause menu
	"""
	if pause_menu:
		pause_menu.visible = true

func hide_pause_menu() -> void:
	"""
	Hide the pause menu
	"""
	if pause_menu:
		pause_menu.visible = false

# Signal handlers
func _on_restart_button_pressed() -> void:
	"""
	Handle restart button press on game over screen
	"""
	hide_game_over()
	# Get reference to main scene and call restart
	var main = get_tree().get_root().get_node("Main")
	if main and main.has_method("restart_game"):
		main.restart_game()

func _on_quit_button_pressed() -> void:
	"""
	Handle quit button press
	"""
	get_tree().quit()

func _on_resume_button_pressed() -> void:
	"""
	Handle resume button press on pause menu
	"""
	hide_pause_menu()
	# Emit signal to unpause the game
	resume_pressed.emit()

# Signals
signal resume_pressed
signal quit_pressed