extends PathFollow2D

@export var speed: float = 60.0
@export var reward: int = 50

# si tu utilises des anims directionnelles :
@export var dir_step_deg: float = 22.5         # 16 directions -> 22.5 ; 8 -> 45.0
@export var anim_prefix: String = "walk_"      # walk_0, walk_22, ..., walk_337
@export var anim_angle_offset: float = 270.0   # ton 0° = haut -> +270
@onready var body: AnimatedSprite2D = $Body
@onready var shadow: AnimatedSprite2D = ($Shadow if has_node("Shadow") else null)

var health: float = 100.0
var world_ref: Node = null
var _last_global_pos: Vector2

func _ready() -> void:
	add_to_group("enemies")
	_last_global_pos = global_position
	if body and body.sprite_frames.has_animation(anim_prefix + "0"):
		body.play(anim_prefix + "0")
	if shadow and shadow.sprite_frames and shadow.sprite_frames.has_animation("walk_shadow_0"):
		shadow.play("walk_shadow_0")

func _process(delta: float) -> void:
	progress += speed * delta

	# (option test) baisse de vie automatique
	health -= delta * 1.0
	if health <= 0.0:
		die()

	# orienter selon mouvement (si anims directionnelles)
	var cur: Vector2 = global_position
	var move: Vector2 = cur - _last_global_pos
	if move.length() > 0.1:
		_update_direction_animation(move)
	_last_global_pos = cur

	if progress_ratio >= 1.0:
		queue_free()

func die() -> void:
	if world_ref:
		world_ref.add_gold(reward)
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
	var snapped: int = int(step_idx * dir_step_deg)  # 0,22,45,...,337

	var anim_name := "%s%d" % [anim_prefix, snapped]
	var shadow_name := "walk_shadow_%d" % snapped

	if body.sprite_frames.has_animation(anim_name) and body.animation != anim_name:
		body.play(anim_name)
	if shadow and shadow.sprite_frames and shadow.sprite_frames.has_animation(shadow_name) and shadow.animation != shadow_name:
		shadow.play(shadow_name)
