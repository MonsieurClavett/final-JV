extends CanvasLayer

@onready var panel: Panel = $Panel
@onready var music_slider: HSlider = $Panel/MusicSlider
@onready var sfx_slider: HSlider = $Panel/SfxSlider
@onready var resume_btn: Button = $Panel/ResumeButton
@onready var main_menu_btn: Button = $Panel/MainMenuButton

var quit_flag := false


var is_open: bool = false

const MIN_DB: float = -40.0
const MAX_DB: float = 0.0
var muted := false
var last_music_db := 0.0
var last_sfx_db := 0.0

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("mute_audio"):
		_toggle_mute()

func _process(_delta : float) -> void:
	if quit_flag:
		get_tree().quit()

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	visible = false
	panel.visible = false

	music_slider.value_changed.connect(_on_music_slider_changed)
	sfx_slider.value_changed.connect(_on_sfx_slider_changed)
	resume_btn.pressed.connect(_on_resume_pressed)
	main_menu_btn.pressed.connect(_on_main_menu_pressed)

	_sync_sliders_with_audio_buses()
	_configure_focus_for_keyboard()


func _configure_focus_for_keyboard() -> void:
	var controls: Array[Control] = [
		resume_btn,
		main_menu_btn,
		music_slider,
		sfx_slider
	]

	for c in controls:
		if c:
			c.focus_mode = Control.FOCUS_ALL

	resume_btn.focus_next = main_menu_btn.get_path()
	main_menu_btn.focus_next = music_slider.get_path()
	music_slider.focus_next = sfx_slider.get_path()
	sfx_slider.focus_next = resume_btn.get_path()

	resume_btn.focus_previous = sfx_slider.get_path()
	main_menu_btn.focus_previous = resume_btn.get_path()
	music_slider.focus_previous = main_menu_btn.get_path()
	sfx_slider.focus_previous = music_slider.get_path()


func open_menu() -> void:
	is_open = true
	visible = true
	panel.visible = true
	get_tree().paused = true

	resume_btn.grab_focus()


func close_menu() -> void:
	is_open = false
	visible = false
	panel.visible = false
	get_tree().paused = false


func toggle_menu() -> void:
	if is_open:
		close_menu()
	else:
		open_menu()

func _on_resume_pressed() -> void:
	close_menu()

func _on_main_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")


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
		
func _toggle_mute() -> void:
	var music_bus := AudioServer.get_bus_index("music")
	var sfx_bus := AudioServer.get_bus_index("sfx")

	if not muted:
		# sauvegarde volumes actuels
		last_music_db = AudioServer.get_bus_volume_db(music_bus)
		last_sfx_db = AudioServer.get_bus_volume_db(sfx_bus)

		# mute complet
		AudioServer.set_bus_volume_db(music_bus, -80.0)
		AudioServer.set_bus_volume_db(sfx_bus, -80.0)
		muted = true
		print("MUTE")

	else:
		# restaure
		AudioServer.set_bus_volume_db(music_bus, last_music_db)
		AudioServer.set_bus_volume_db(sfx_bus, last_sfx_db)
		muted = false
		print("UNMUTE")
