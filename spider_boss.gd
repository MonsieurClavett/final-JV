extends PathFollow2D

@export var speed: float = 200.0
@export var reward: int = 50

@export var dir_step_deg: float = 22.5
@export var anim_prefix: String = "walk_"
@export var anim_angle_offset: float = 90.0

@export var max_health: float = 100.0

@onready var body: AnimatedSprite2D = $Body
@onready var shadow: AnimatedSprite2D = ($Shadow if has_node("Shadow") else null)
@onready var health_bar_fg: ColorRect = $HealthBar/FG

var health: float
var world_ref: Node = null
var _last_global_pos: Vector2
var _health_bar_full_width: float = 0.0
var is_dying: bool = false




func _ready() -> void:
	add_to_group("enemies")
	_last_global_pos = global_position

	health = max_health

	if health_bar_fg:
		_health_bar_full_width = health_bar_fg.size.x
		if _health_bar_full_width <= 0.0:
			_health_bar_full_width = 40.0  

	_update_health_bar()

	if body and body.sprite_frames.has_animation(anim_prefix + "0"):
		body.play(anim_prefix + "0")
	if shadow and shadow.sprite_frames and shadow.sprite_frames.has_animation("walk_shadow_0"):
		shadow.play("walk_shadow_0")



func _process(delta: float) -> void:
	if is_dying:
		return  

	progress += speed * delta

	_update_health_bar()

	var cur: Vector2 = global_position
	var move: Vector2 = cur - _last_global_pos
	if move.length() > 0.1:
		_update_direction_animation(move)
	_last_global_pos = cur

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
	remove_from_group("enemies")

	if world_ref:
		world_ref.add_gold(reward)

	set_process(false)
	set_physics_process(false)
	set_process(true) 

	var has_death_anim := false

	if body and body.sprite_frames.has_animation("death"):
		body.play("death")
		has_death_anim = true

	if shadow and shadow.sprite_frames and shadow.sprite_frames.has_animation("death"):
		shadow.play("death")

	if has_death_anim:
		await body.animation_finished
		await get_tree().create_timer(0.5).timeout 

	remove_from_group("enemies")
	set_process(false)
	set_physics_process(false)
	queue_free()





func _update_direction_animation(dir: Vector2) -> void:
	if body == null:
		return

	var ang: float = rad_to_deg(atan2(dir.y, dir.x))
	if ang < 0.0:
		ang += 360.0

	ang = fmod(ang + anim_angle_offset + 360.0, 360.0)

	var steps_total: int = int(360.0 / dir_step_deg)
	var step_idx: int = int(round(ang / dir_step_deg)) % steps_total
	var snapped: int = int(step_idx * dir_step_deg)

	var anim_name := "%s%d" % [anim_prefix, snapped]
	var shadow_name := "walk_shadow_%d" % snapped

	if body.sprite_frames.has_animation(anim_name) and body.animation != anim_name:
		body.play(anim_name)
	if shadow and shadow.sprite_frames and shadow.animation != shadow_name \
	and shadow.sprite_frames.has_animation(shadow_name):
		shadow.play(shadow_name)


func _update_health_bar() -> void:
	if health_bar_fg == null:
		return

	var ratio: float = 0.0
	if max_health > 0.0:
		ratio = clamp(health / max_health, 0.0, 1.0)

	# largeur initiale * ratio
	var full_width: float = _health_bar_full_width
	health_bar_fg.size.x = full_width * ratio

	# couleur vert -> rouge
	var color: Color = Color(1.0 - ratio, ratio, 0.0)
	health_bar_fg.color = color
