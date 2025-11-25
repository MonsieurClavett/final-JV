extends PathFollow2D

@export var speed: float = 400.0
@export var max_health: float = 10.0
@export var reward: int = 10

var health: float
var is_dying: bool = false
var world_ref: Node = null
var _last_global_pos: Vector2
var _health_bar_full_width: float = 0.0

@onready var body: AnimatedSprite2D = $AnimatedSprite2D
@onready var shadow: AnimatedSprite2D = $Shadow
@onready var health_bar_fg: ColorRect = $HealthBar/FG


func _ready() -> void:
	_last_global_pos = global_position
	health = max_health

	add_to_group("enemies") 

	if health_bar_fg:
		_health_bar_full_width = health_bar_fg.size.x
		if _health_bar_full_width <= 0.0:
			_health_bar_full_width = 40.0

	_update_health_bar()

	if body and body.sprite_frames.has_animation("run_0"):
		body.play("run_0")
	if shadow and shadow.sprite_frames.has_animation("run_0"):
		shadow.play("run_0")


func _process(delta: float) -> void:
	if is_dying:
		return  

	progress += speed * delta

	var current_pos: Vector2 = global_position
	var move: Vector2 = current_pos - _last_global_pos
	if move.length() > 0.1:
		_update_direction_animation(move)
	_last_global_pos = current_pos

	if progress_ratio >= 1.0:
		if world_ref and world_ref.has_method("game_over"):
			world_ref.game_over()
		queue_free()


func take_damage(amount: float) -> void:
	if is_dying:
		return

	health -= amount
	if health <= 0.0:
		health = 0.0
		_update_health_bar()
		die()
	else:
		_update_health_bar()


func die() -> void:
	if is_dying:
		return
	is_dying = true

	# ⬇ très important : ne plus faire partie des cibles
	remove_from_group("enemies")

	if world_ref and world_ref.has_method("add_gold"):
		world_ref.add_gold(reward)

	var has_death_anim: bool = false

	if body and body.sprite_frames.has_animation("death"):
		body.play("death")
		has_death_anim = true

	if shadow and shadow.sprite_frames and shadow.sprite_frames.has_animation("death"):
		shadow.play("death")

	if has_death_anim:
		await body.animation_finished

	queue_free()


func _update_direction_animation(dir: Vector2) -> void:
	if body == null:
		return

	var angle: float = rad_to_deg(atan2(dir.y, dir.x))
	if angle < 0.0:
		angle += 360.0

	var step: float = 45.0
	var index: int = int(round(angle / step)) % 8
	var snapped_angle: int = index * int(step)
	var anim_name := "run_%d" % snapped_angle

	if body.sprite_frames.has_animation(anim_name) and body.animation != anim_name:
		body.play(anim_name)
	if shadow and shadow.sprite_frames.has_animation(anim_name) and shadow.animation != anim_name:
		shadow.play(anim_name)


func _update_health_bar() -> void:
	if health_bar_fg == null:
		return

	var ratio: float = 0.0
	if max_health > 0.0:
		ratio = clamp(health / max_health, 0.0, 1.0)

	var full_width: float = _health_bar_full_width
	health_bar_fg.size.x = full_width * ratio

	var color: Color = Color(1.0 - ratio, ratio, 0.0)
	health_bar_fg.color = color
