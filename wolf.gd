# Wolf.gd
extends PathFollow2D

@export var speed: float = 80.0
@export var max_health: int = 10
@export var health_decrease_rate: float = 1.0
@export var reward: int = 5

var health: float
var _last_global_pos: Vector2
var is_dead: bool = false

var world_ref: Node = null
@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D


func _ready() -> void:
	_last_global_pos = global_position
	health = max_health
	if sprite:
		sprite.play("run_45")


func _process(delta: float) -> void:
	if is_dead:
		return

	progress += speed * delta
	health -= health_decrease_rate * delta
	health = clamp(health, 0.0, max_health)

	var current_pos = global_position
	var move = current_pos - _last_global_pos
	if move.length() > 0.1:
		_update_direction_animation(move)
	_last_global_pos = current_pos

	if health <= 0.0:
		die()
	elif progress_ratio >= 1.0:
		queue_free()


func die() -> void:
	if is_dead:
		return
	is_dead = true

	if world_ref:
		world_ref.add_gold(reward)

	if sprite.sprite_frames.has_animation("death"):
		sprite.play("death")
		sprite.animation_finished.connect(func(): queue_free(), CONNECT_ONE_SHOT)
	else:
		queue_free()


func _update_direction_animation(dir: Vector2) -> void:
	var angle = rad_to_deg(atan2(dir.y, dir.x))
	if angle < 0:
		angle += 360.0

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
	if sprite.sprite_frames.has_animation(anim_name) \
	and sprite.animation != anim_name:
		sprite.play(anim_name)
