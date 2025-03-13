# Audio Manager
# Global singleton for managing game audio
extends Node

# Constants
const MUSIC_BUS_IDX = 1
const SFX_BUS_IDX = 2

# Exported variables
@export var default_music_volume: float = 0.8
@export var default_sfx_volume: float = 1.0

# Public variables
var music_players: Array[AudioStreamPlayer] = []
var current_music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []

# Private variables
var _music_tracks: Dictionary = {}
var _sound_effects: Dictionary = {}
var _current_track: String = ""
var _music_volume: float
var _sfx_volume: float
var _music_fading: bool = false

# Built-in virtual methods
func _ready() -> void:
	# Initialize audio system
	_initialize_audio_buses()
	_create_audio_players()
	
	# Set default volumes
	_music_volume = default_music_volume
	_sfx_volume = default_sfx_volume
	
	# Apply volumes from GameManager if available
	if has_node("/root/GameManager"):
		var game_manager = get_node("/root/GameManager")
		if game_manager.settings.has("music_volume"):
			_music_volume = game_manager.settings.music_volume
		if game_manager.settings.has("sfx_volume"):
			_sfx_volume = game_manager.settings.sfx_volume
		
		# Connect to settings changed signal
		if game_manager.has_signal("settings_changed"):
			game_manager.settings_changed.connect(_on_settings_changed)
	
	# Apply volumes
	set_music_volume(_music_volume)
	set_sfx_volume(_sfx_volume)

# Public methods
func preload_music(track_name: String, stream: AudioStream) -> void:
	"""
	Preload a music track for later use
	"""
	_music_tracks[track_name] = stream

func preload_sound(sound_name: String, stream: AudioStream) -> void:
	"""
	Preload a sound effect for later use
	"""
	_sound_effects[sound_name] = stream

func play_music(track_name: String, fade_time: float = 1.0, volume: float = 1.0) -> void:
	"""
	Play a music track with optional fade-in
	"""
	if _current_track == track_name and current_music_player and current_music_player.playing:
		return
	
	if not _music_tracks.has(track_name):
		push_warning("Music track not found: " + track_name)
		return
	
	_current_track = track_name
	
	# Find an available music player
	var next_player: AudioStreamPlayer
	for player in music_players:
		if not player.playing or player != current_music_player:
			next_player = player
			break
	
	if not next_player:
		next_player = music_players[0]
	
	# Set up the new track
	next_player.stream = _music_tracks[track_name]
	next_player.volume_db = linear_to_db(0.0)  # Start silent for fade-in
	next_player.play()
	
	# Fade in the new track and fade out the old one
	if fade_time > 0:
		_music_fading = true
		
		var tween = create_tween()
		tween.tween_property(next_player, "volume_db", linear_to_db(_music_volume * volume), fade_time)
		
		if current_music_player and current_music_player.playing:
			tween.parallel().tween_property(current_music_player, "volume_db", linear_to_db(0.0), fade_time)
			tween.tween_callback(func(): current_music_player.stop())
		
		tween.tween_callback(func(): _music_fading = false)
	else:
		next_player.volume_db = linear_to_db(_music_volume * volume)
		if current_music_player and current_music_player.playing:
			current_music_player.stop()
	
	current_music_player = next_player

func stop_music(fade_time: float = 1.0) -> void:
	"""
	Stop the currently playing music with optional fade-out
	"""
	if not current_music_player or not current_music_player.playing:
		return
	
	if fade_time > 0:
		_music_fading = true
		
		var tween = create_tween()
		tween.tween_property(current_music_player, "volume_db", linear_to_db(0.0), fade_time)
		tween.tween_callback(func(): 
			current_music_player.stop()
			_music_fading = false
		)
	else:
		current_music_player.stop()
	
	_current_track = ""

func play_sound(sound_name: String, volume: float = 1.0, pitch: float = 1.0) -> AudioStreamPlayer:
	"""
	Play a sound effect
	Returns the AudioStreamPlayer used to play the sound
	"""
	if not _sound_effects.has(sound_name):
		push_warning("Sound effect not found: " + sound_name)
		return null
	
	# Find an available sound player
	var player: AudioStreamPlayer
	for p in sfx_players:
		if not p.playing:
			player = p
			break
	
	# If no player is available, create a new one
	if not player:
		player = _create_sfx_player()
		sfx_players.append(player)
	
	# Set up and play the sound
	player.stream = _sound_effects[sound_name]
	player.volume_db = linear_to_db(_sfx_volume * volume)
	player.pitch_scale = pitch
	player.play()
	
	return player

func set_music_volume(volume: float) -> void:
	"""
	Set the music volume (0.0 to 1.0)
	"""
	_music_volume = clamp(volume, 0.0, 1.0)
	AudioServer.set_bus_volume_db(MUSIC_BUS_IDX, linear_to_db(_music_volume))
	
	# Update current music player if not fading
	if current_music_player and current_music_player.playing and not _music_fading:
		current_music_player.volume_db = linear_to_db(_music_volume)

func set_sfx_volume(volume: float) -> void:
	"""
	Set the sound effects volume (0.0 to 1.0)
	"""
	_sfx_volume = clamp(volume, 0.0, 1.0)
	AudioServer.set_bus_volume_db(SFX_BUS_IDX, linear_to_db(_sfx_volume))

# Private methods
func _initialize_audio_buses() -> void:
	"""
	Set up audio buses if they don't exist
	"""
	# Ensure we have the required buses
	if AudioServer.get_bus_count() < 3:
		# Master bus is always index 0
		
		# Add Music bus if it doesn't exist
		if AudioServer.get_bus_index("Music") == -1:
			AudioServer.add_bus()
			AudioServer.set_bus_name(MUSIC_BUS_IDX, "Music")
		
		# Add SFX bus if it doesn't exist
		if AudioServer.get_bus_index("SFX") == -1:
			AudioServer.add_bus()
			AudioServer.set_bus_name(SFX_BUS_IDX, "SFX")

func _create_audio_players() -> void:
	"""
	Create audio player nodes
	"""
	# Create music players (we use 2 for crossfading)
	for i in range(2):
		var player = AudioStreamPlayer.new()
		player.bus = "Music"
		add_child(player)
		music_players.append(player)
	
	# Create initial pool of sound effect players
	for i in range(8):  # Start with 8 players
		var player = _create_sfx_player()
		sfx_players.append(player)

func _create_sfx_player() -> AudioStreamPlayer:
	"""
	Create and return a new sound effect player
	"""
	var player = AudioStreamPlayer.new()
	player.bus = "SFX"
	add_child(player)
	return player

# Signal handlers
func _on_settings_changed() -> void:
	"""
	Handle settings changed in GameManager
	"""
	if has_node("/root/GameManager"):
		var game_manager = get_node("/root/GameManager")
		
		if game_manager.settings.has("music_volume"):
			set_music_volume(game_manager.settings.music_volume)
		
		if game_manager.settings.has("sfx_volume"):
			set_sfx_volume(game_manager.settings.sfx_volume)