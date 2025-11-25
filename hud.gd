extends CanvasLayer

@onready var gold_label: Label = $GoldLabel
@onready var wave_label: Label = $WaveLabel
@onready var game_over_label: Label = $GameOverLabel

func _ready() -> void:
	# au cas où
	if game_over_label:
		game_over_label.visible = false

func update_gold(value: int) -> void:
	if gold_label:
		gold_label.text = "Gold: %d" % value

func update_wave(value: int) -> void:
	if wave_label:
		wave_label.text = "Wave: %d" % value

func show_game_over() -> void:
	if game_over_label:
		game_over_label.visible = true
		print("HUD: show_game_over() appelé")
