# Main UI
# Handles the main game UI elements
extends CanvasLayer

# Onready variables
@onready var health_bar = $HealthBar
@onready var score_label = $ScoreLabel
@onready var pause_menu = $PauseMenu
@onready var game_over_panel = $GameOverPanel

# Signals
signal resume_pressed
signal restart_pressed
signal quit_pressed

# Built-in virtual methods
func _ready() -> void:
	# Initialize UI elements
	pause_menu.visible = false
	game_over_panel.visible = false
	update_health(100)
	update_score(0)

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
	restart_pressed.emit()

func _on_quit_button_pressed() -> void:
	"""
	Handle quit button press
	"""
	quit_pressed.emit()

func _on_resume_button_pressed() -> void:
	"""
	Handle resume button press on pause menu
	"""
	hide_pause_menu()
	resume_pressed.emit()
