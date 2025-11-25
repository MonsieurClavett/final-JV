extends Node2D

var enabled: bool = false

func _process(delta: float) -> void:
	# on redessine tout le temps
	queue_redraw()

func _draw() -> void:
	if not enabled:
		# on ne dessine rien → ça efface ce qu’il y avait avant
		return

	# ici: tes flèches / vecteurs
	# exemple:
	var towers = get_tree().get_nodes_in_group("towers")
	for t in towers:
		if not (t is Node2D):
			continue
		var tower := t as Node2D
		if not ("target" in tower):
			continue
		var target = tower.target
		if target == null or not is_instance_valid(target):
			continue

		var from: Vector2 = tower.global_position
		var to: Vector2 = target.global_position

		var from_local = to_local(from)
		var to_local_pos = to_local(to)
		_draw_arrow(from_local, to_local_pos, Color.RED)


func _draw_arrow(from: Vector2, to: Vector2, color: Color) -> void:
	draw_line(from, to, color, 2.0)
	var dir := (to - from).normalized()
	var left := dir.rotated(deg_to_rad(150.0)) * 10.0
	var right := dir.rotated(deg_to_rad(-150.0)) * 10.0
	draw_line(to, to + left, color, 2.0)
	draw_line(to, to + right, color, 2.0)
