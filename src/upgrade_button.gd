extends Button

var tower_ref: Node = null
var world_ref: Node = null

func setup(tower, world) -> void:
	tower_ref = tower
	world_ref = world
	pressed.connect(_on_pressed)
	_refresh()
	
	if world_ref and world_ref.has_method("refresh_shop_buttons"):
		world_ref.call_deferred("refresh_shop_buttons")

func _on_pressed() -> void:
	if tower_ref == null or world_ref == null:
		push_error("UpgradeButton: refs manquantes")
		return

	var ok: bool = tower_ref.try_upgrade(world_ref)
	if ok:
		_refresh()

func _refresh() -> void:
	if tower_ref == null:
		return

	if tower_ref.has_method("get_current_upgrade_cost"):
		var cost: int = tower_ref.get_current_upgrade_cost()

		if cost <= 0:
			text = "Max"
			disabled = true
		else:
			text = "%d" % cost
			disabled = false
