extends PathFollow2D

@export var speed: float = 60.0

var _last_global_pos: Vector2
@onready var body: AnimatedSprite2D = $AnimatedSprite2D
@onready var shadow: AnimatedSprite2D = $Shadow

func _ready() -> void:
	_last_global_pos = global_position
	body.play("run_0")
	shadow.play("run_0")

func _process(delta: float) -> void:
	progress += speed * delta

	var current_pos = global_position
	var move = current_pos - _last_global_pos
	if move.length() > 0.1:
		_update_direction_animation(move)
	_last_global_pos = current_pos

	if progress_ratio >= 1.0:
		queue_free()

func _update_direction_animation(dir: Vector2) -> void:
	var angle = rad_to_deg(atan2(dir.y, dir.x))
	if angle < 0:
		angle += 360.0

	# 8 directions : 0,45,90,...,315
	var step := 45.0
	var index: int = int(round(angle / step)) % 8
	var snapped_angle: int = index * int(step)
	var anim_name := "run_%d" % snapped_angle

	if body.sprite_frames.has_animation(anim_name):
		if body.animation != anim_name:
			body.play(anim_name)
			if shadow.sprite_frames.has_animation(anim_name):
				shadow.play(anim_name)
