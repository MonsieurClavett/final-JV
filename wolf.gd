extends PathFollow2D

@export var speed: float = 80.0

var _last_global_pos: Vector2

func _ready() -> void:
	_last_global_pos = global_position
	if has_node("AnimatedSprite2D"):
		$AnimatedSprite2D.play("run_45") # par défaut

func _process(delta: float) -> void:
	# avancer sur le chemin
	progress += speed * delta

	# choisir anim selon direction
	var current_pos = global_position
	var move = current_pos - _last_global_pos
	if move.length() > 0.1:
		_update_direction_animation(move)
	_last_global_pos = current_pos

	# fin du chemin
	if progress_ratio >= 1.0:
		queue_free()


func _update_direction_animation(dir: Vector2) -> void:
	var angle = rad_to_deg(atan2(dir.y, dir.x))
	if angle < 0:
		angle += 360.0

	# angles des 4 directions dispo dans ta spritesheet
	var target_angles = [45.0, 135.0, 225.0, 315.0]
	var anim_names = ["run_45", "run_135", "run_225", "run_315"]

	var best_index = 0
	var best_diff = 9999.0

	for i in target_angles.size():
		var diff = abs(angle - target_angles[i])
		if diff > 180.0:
			diff = 360.0 - diff
		if diff < best_diff:
			best_diff = diff
			best_index = i

	var anim_name = anim_names[best_index]

	if $AnimatedSprite2D.animation != anim_name \
	and $AnimatedSprite2D.sprite_frames.has_animation(anim_name):
		$AnimatedSprite2D.play(anim_name)
