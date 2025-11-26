extends Control

@export var game_scene: PackedScene

@onready var panel_root: Panel = $Panel

@onready var settings_panel: Panel = $SettingsPanel
@onready var controls_panel: Panel = $ControlsPanel
@onready var instructions_panel: Panel = $InstructionsPanel

@onready var play_button: Button = $Panel/PlayButton
@onready var settings_button: Button = $Panel/SettingsButton
@onready var controls_button: Button = $Panel/ControlsButton
@onready var instructions_button: Button = $Panel/InstructionsButton
@onready var quit_button: Button = $Panel/QuitButton

@onready var music_slider: HSlider = $SettingsPanel/MusicSlider
@onready var sfx_slider: HSlider = $SettingsPanel/SfxSlider
@onready var back_settings_button: Button = $SettingsPanel/BackFromSettings
@onready var bg_anim: AnimatedSprite2D = $AnimatedSprite2D   # adapte le chemin si besoin

# Nouveaux
@onready var back_controls_button: Button = $ControlsPanel/BackFromControls
@onready var back_instructions_button: Button = $InstructionsPanel/BackFromInstructions


func _ready() -> void:
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


# ----------------------------------------------------
# Volume sliders
# ----------------------------------------------------

func _on_music_slider_changed(value: float) -> void:
	var ratio: float = clampf(value / 100.0, 0.0, 1.0)
	var db: float = lerpf(-40.0, 0.0, ratio)
	var bus_idx: int = AudioServer.get_bus_index("music")
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, db)


func _on_sfx_slider_changed(value: float) -> void:
	var ratio: float = clampf(value / 100.0, 0.0, 1.0)
	var db: float = lerpf(-40.0, 0.0, ratio)
	var bus_idx: int = AudioServer.get_bus_index("sfx")
	if bus_idx >= 0:
		AudioServer.set_bus_volume_db(bus_idx, db)
		
