extends Button

@export var cost: int = 50
@export var world: Node  

func _ready() -> void:
	if world == null:
		world = get_tree().current_scene
	pressed.connect(_on_pressed)

func _on_pressed() -> void:
	if world == null:
		push_error("BuildButton: world ref manquante")
		return
	var ok: bool = world.try_buy_tower(cost, global_position)
	if ok:
		queue_free()
