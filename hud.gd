extends CanvasLayer

@onready var gold_label: Label = $GoldLabel

func update_gold(value: int) -> void:
	if gold_label:
		gold_label.text = "Gold: %d" % value
