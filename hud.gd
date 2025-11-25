extends CanvasLayer

@onready var gold_label: Label = $GoldLabel
@onready var wave_label: Label = $WaveLabel
@onready var game_over_label: Label = $GameOverLabel
@onready var game_over_menu: VBoxContainer = $GameOverMenu
@onready var restart_btn: Button = $GameOverMenu/RestartButton
@onready var exit_btn: Button = $GameOverMenu/ExitButton

func _ready() -> void:
	process_mode = 2



	# Cache le menu de game over au début
	game_over_label.visible = false
	game_over_menu.visible = false

	# Connexions
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
	print("HUD: Game Over affiché")

func _on_restart_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene()

func _on_exit_pressed() -> void:
	get_tree().quit()
