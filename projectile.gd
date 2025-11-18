extends Node2D

@export var speed: float = 400.0
@export var damage: int = 49

var target: Node2D = null

func _physics_process(delta: float) -> void:
	if target == null or not is_instance_valid(target):
		queue_free()
		return

	var dir = (target.global_position - global_position).normalized()

	rotation = dir.angle()
	global_position += dir * speed * delta

	if global_position.distance_to(target.global_position) < 12.0:
		if target.has_method("take_damage"):
			target.take_damage(damage)
		queue_free()
