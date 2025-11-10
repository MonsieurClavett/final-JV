extends Button

@export var cost: int = 50
@export var world: Node  # référence vers le node World

func _ready() -> void:
	if world == null:
		# essaie de trouver automatiquement le node "World"
		world = get_tree().get_root().find_child("World", true, false)
	connect("pressed", Callable(self, "_on_pressed"))

func _on_pressed() -> void:
	if world == null:
		push_error("BuildButton: world ref manquante")
		return

	var ok: bool = world.try_buy_tower(cost, global_position)
	if ok:
		queue_free()  # supprime le bouton après achat
