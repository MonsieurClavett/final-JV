extends CanvasLayer

@onready var gold_label: Label = $GoldLabel
@onready var wave_label: Label = $WaveLabel
@onready var game_over_label: Label = $GameOverLabel
@onready var game_over_menu: VBoxContainer = $GameOverMenu
@onready var restart_btn: Button = $GameOverMenu/RestartButton
@onready var exit_btn: Button = $GameOverMenu/ExitButton
@onready var debug_label: Label = $DebugLabel
@onready var red_overlay: ColorRect = $RedOverlay
@onready var menu_btn: Button = $GameOverMenu/MenuButton 


func _ready() -> void:
	if red_overlay:
		red_overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
	# le HUD doit continuer même en pause
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	game_over_label.visible = false
	game_over_menu.visible = false
	debug_label.visible = false
	
	restart_btn.pressed.connect(_on_restart_pressed)
	exit_btn.pressed.connect(_on_exit_pressed)
	menu_btn.pressed.connect(_on_menu_pressed)
	
	_configure_game_over_focus()



func update_gold(value: int) -> void:
	if gold_label:
		gold_label.text = "Gold: %d" % value


func update_wave(value: int) -> void:
	if wave_label:
		wave_label.text = "Wave: %d" % value


func _configure_game_over_focus() -> void:
	var controls: Array[Control] = [restart_btn, menu_btn, exit_btn]
	for c in controls:
		if c:
			c.focus_mode = Control.FOCUS_ALL

	# ordre ↓ : Restart -> Menu -> Quit -> Restart
	restart_btn.focus_next = menu_btn.get_path()
	menu_btn.focus_next = exit_btn.get_path()
	exit_btn.focus_next = restart_btn.get_path()

	# ordre ↑ : l’inverse
	restart_btn.focus_previous = exit_btn.get_path()
	menu_btn.focus_previous = restart_btn.get_path()
	exit_btn.focus_previous = menu_btn.get_path()



func show_game_over() -> void:
	game_over_label.visible = true
	game_over_menu.visible = true

	if red_overlay:
		red_overlay.visible = true

	# 🎯 bouton par défaut quand le game over apparaît
	restart_btn.grab_focus()


func set_debug_mode(active: bool) -> void:
	debug_label.visible = active
	print("HUD: debug mode =", active)


func _process(delta: float) -> void:
	var fps: int = Engine.get_frames_per_second()

	var mem_mb: float = 0.0
	if OS.has_method("get_static_memory_usage"):
		var mem_bytes: int = OS.get_static_memory_usage()
		mem_mb = float(mem_bytes) / (1024.0 * 1024.0)

	var text := "DEBUG\n"
	text += "FPS: " + str(fps) + "\n"
	text += "RAM: " + str(round(mem_mb * 10.0) / 10.0) + " MB"

	debug_label.text = text



func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()


func _on_exit_pressed() -> void:
	get_tree().quit()
	
func _on_menu_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://main_menu.tscn")  # <-- mets ton chemin réel
