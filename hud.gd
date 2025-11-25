extends CanvasLayer

@onready var gold_label: Label = $GoldLabel
@onready var wave_label: Label = $WaveLabel
@onready var game_over_label: Label = $GameOverLabel
@onready var game_over_menu: VBoxContainer = $GameOverMenu
@onready var restart_btn: Button = $GameOverMenu/RestartButton
@onready var exit_btn: Button = $GameOverMenu/ExitButton
@onready var debug_label: Label = $DebugLabel


func _ready() -> void:
	# le HUD doit continuer même en pause
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	game_over_label.visible = false
	game_over_menu.visible = false
	debug_label.visible = false
	
	restart_btn.pressed.connect(_on_restart_pressed)
	exit_btn.pressed.connect(_on_exit_pressed)


func update_gold(value: int) -> void:
	if gold_label:
		gold_label.text = "Gold: %d" % value


func update_wave(value: int) -> void:
	if wave_label:
		wave_label.text = "Wave: %d" % value


func show_game_over() -> void:
	game_over_label.visible = true
	game_over_menu.visible = true


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
