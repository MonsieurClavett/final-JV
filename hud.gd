extends CanvasLayer

@onready var gold_label: Label = $GoldLabel
@onready var wave_label: Label = $WaveLabel

func update_gold(value: int) -> void:
	if gold_label:
		gold_label.text = "Gold: %d" % value

func update_wave(value: int) -> void:
	if wave_label:
		wave_label.text = "Wave: %d" % value
