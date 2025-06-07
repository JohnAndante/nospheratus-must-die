extends Node

signal settings_changed

# Configurações de áudio
var master_volume: float = 1.0
var music_volume: float = 0.8
var sfx_volume: float = 1.0

# Configurações de vídeo
var fullscreen: bool = false
var vsync: bool = true

# Configurações de controle
var language: String = "pt-br"

# Arquivo de configuração
const SETTINGS_FILE = "user://settings.cfg"

func _ready():
	load_settings()
	apply_settings()

func save_settings():
	var config = ConfigFile.new()

	config.set_value("audio", "master_volume", master_volume)
	config.set_value("audio", "music_volume", music_volume)
	config.set_value("audio", "sfx_volume", sfx_volume)

	config.set_value("video", "fullscreen", fullscreen)
	config.set_value("video", "vsync", vsync)

	config.set_value("game", "language", language)

	config.save(SETTINGS_FILE)

func load_settings():
	var config = ConfigFile.new()

	if config.load(SETTINGS_FILE) != OK:
		return # Usar valores padrão

	master_volume = config.get_value("audio", "master_volume", 1.0)
	music_volume = config.get_value("audio", "music_volume", 0.8)
	sfx_volume = config.get_value("audio", "sfx_volume", 1.0)

	fullscreen = config.get_value("video", "fullscreen", false)
	vsync = config.get_value("video", "vsync", true)

	language = config.get_value("game", "language", "pt-br")

func apply_settings():
	# Aplicar configurações de áudio
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume))

	# Aplicar configurações de vídeo
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

	# V-Sync
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED if vsync else DisplayServer.VSYNC_DISABLED)

	settings_changed.emit()

func set_master_volume(value: float):
	master_volume = clamp(value, 0.0, 1.0)
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume))
	settings_changed.emit()

func set_fullscreen(enabled: bool):
	fullscreen = enabled
	if fullscreen:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	else:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	settings_changed.emit()

func toggle_fullscreen():
	set_fullscreen(!fullscreen)
