extends Control

@export var game_scene: PackedScene

@onready var panel_root: Control = $Panel

@onready var settings_panel: Panel = $SettingsPanel
@onready var controls_panel: Panel = $ControlsPanel
@onready var instructions_panel: Panel = $InstructionsPanel

@onready var play_button: Button = $Panel/VBoxContainer/PlayButton
@onready var settings_button: Button = $Panel/VBoxContainer/SettingsButton
@onready var controls_button: Button = $Panel/VBoxContainer/ControlsButton
@onready var instructions_button: Button = $Panel/VBoxContainer/InstructionsButton
@onready var quit_button: Button = $Panel/VBoxContainer/QuitButton

@onready var music_slider: HSlider = $SettingsPanel/MusicSlider
@onready var sfx_slider: HSlider = $SettingsPanel/SfxSlider
@onready var back_settings_button: Button = $SettingsPanel/BackFromSettings
@onready var bg_anim: AnimatedSprite2D = $AnimatedSprite2D   # adapte le chemin si besoin

# Nouveaux
@onready var back_controls_button: Button = $ControlsPanel/BackFromControls
@onready var back_instructions_button: Button = $InstructionsPanel/BackFromInstructions

@onready var highscore_label: Label = $Panel/HighScoreLabel
var save_path := "user://GameSave.tres"


const MIN_DB: float = -40.0
const MAX_DB: float = 0.0

func _ready() -> void:
	var best := _load_highest_wave()
	highscore_label.text = "highest wave : %d" % best
	bg_anim.play("bg")
	
	# Connexions des boutons du menu principal
	play_button.pressed.connect(_on_play_pressed)
	settings_button.pressed.connect(_on_settings_pressed)
	controls_button.pressed.connect(_on_controls_pressed)
	instructions_button.pressed.connect(_on_instructions_pressed)
	quit_button.pressed.connect(_on_quit_pressed)

	# Back buttons
	back_settings_button.pressed.connect(_on_back_pressed)
	back_controls_button.pressed.connect(_on_back_pressed)
	back_instructions_button.pressed.connect(_on_back_pressed)

	# Sliders
	music_slider.value_changed.connect(_on_music_slider_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)

	# Panels cachés au début
	settings_panel.visible = false
	controls_panel.visible = false
	instructions_panel.visible = false

	_sync_sliders_with_audio_buses()

	# 💡 Important : configuration du focus pour le jeu au clavier
	_configure_focus_for_keyboard()

	# On commence sur le bouton "Play"
	play_button.grab_focus()
	# (optionnel) cacher la souris :
	# Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)


# ----------------------------------------------------
# Configuration du focus clavier
# ----------------------------------------------------
func _configure_focus_for_keyboard() -> void:
	# S’assurer que tous les contrôles importants peuvent prendre le focus
	var buttons: Array[Control] = [
		play_button,
		settings_button,
		controls_button,
		instructions_button,
		quit_button,
		back_settings_button,
		back_controls_button,
		back_instructions_button,
		music_slider,
		sfx_slider
	]

	for c in buttons:
		if c:
			c.focus_mode = Control.FOCUS_ALL

	# 🔽 Ordre de navigation dans le menu principal (flèches haut/bas)
	# Play -> Settings -> Controls -> Instructions -> Quit -> Play (boucle)
	play_button.focus_next = settings_button.get_path()
	settings_button.focus_next = controls_button.get_path()
	controls_button.focus_next = instructions_button.get_path()
	instructions_button.focus_next = quit_button.get_path()
	quit_button.focus_next = play_button.get_path()

	play_button.focus_previous = quit_button.get_path()
	settings_button.focus_previous = play_button.get_path()
	controls_button.focus_previous = settings_button.get_path()
	instructions_button.focus_previous = controls_button.get_path()
	quit_button.focus_previous = instructions_button.get_path()

	# Pour le panneau Settings, on peut définir :
	# MusicSlider <-> SfxSlider <-> BackFromSettings
	music_slider.focus_next = sfx_slider.get_path()
	sfx_slider.focus_next = back_settings_button.get_path()
	back_settings_button.focus_next = music_slider.get_path()

	music_slider.focus_previous = back_settings_button.get_path()
	sfx_slider.focus_previous = music_slider.get_path()
	back_settings_button.focus_previous = sfx_slider.get_path()


# ----------------------------------------------------
# Navigation entre panels
# ----------------------------------------------------

func _on_play_pressed() -> void:
	get_tree().change_scene_to_packed(game_scene)


func _on_settings_pressed() -> void:
	_show_panel(settings_panel)


func _on_controls_pressed() -> void:
	_show_panel(controls_panel)


func _on_instructions_pressed() -> void:
	_show_panel(instructions_panel)


func _on_quit_pressed() -> void:
	get_tree().quit()


func _on_back_pressed() -> void:
	_show_panel(null)


func _show_panel(panel: Panel) -> void:
	panel_root.visible = (panel == null)
	settings_panel.visible = (panel == settings_panel)
	controls_panel.visible = (panel == controls_panel)
	instructions_panel.visible = (panel == instructions_panel)

	# 🎯 Très important : donner le focus au bon contrôle quand on change de panneau
	if panel == null:
		# Retour au menu principal
		play_button.grab_focus()
	elif panel == settings_panel:
		# On commence par le slider musique
		music_slider.grab_focus()
	elif panel == controls_panel:
		# Par exemple, le bouton "Back"
		back_controls_button.grab_focus()
	elif panel == instructions_panel:
		back_instructions_button.grab_focus()


# ----------------------------------------------------
# Volume sliders
# ----------------------------------------------------
func _on_music_slider_changed(value: float) -> void:
	var ratio: float = clampf(value / 100.0, 0.0, 1.0)
	var db: float = lerpf(MIN_DB, MAX_DB, ratio)
	var bus_idx: int = AudioServer.get_bus_index("music")
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, db)


func _on_sfx_slider_changed(value: float) -> void:
	var ratio: float = clampf(value / 100.0, 0.0, 1.0)
	var db: float = lerpf(MIN_DB, MAX_DB, ratio)
	var bus_idx: int = AudioServer.get_bus_index("sfx")
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, db)

func _sync_sliders_with_audio_buses() -> void:
	var music_idx: int = AudioServer.get_bus_index("music")
	if music_idx >= 0:
		var db: float = AudioServer.get_bus_volume_db(music_idx)
		var ratio: float = inverse_lerp(MIN_DB, MAX_DB, db)
		music_slider.value = clampf(ratio * 100.0, 0.0, 100.0)

	var sfx_idx: int = AudioServer.get_bus_index("sfx")
	if sfx_idx >= 0:
		var db_sfx: float = AudioServer.get_bus_volume_db(sfx_idx)
		var ratio_sfx: float = inverse_lerp(MIN_DB, MAX_DB, db_sfx)
		sfx_slider.value = clampf(ratio_sfx * 100.0, 0.0, 100.0)

func _load_highest_wave() -> int:
	if FileAccess.file_exists(save_path):
		var data = ResourceLoader.load(save_path)
		if data:
			return data.highest_wave
	
	return 0  # si pas encore de fichier
