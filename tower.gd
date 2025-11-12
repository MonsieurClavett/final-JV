extends Node2D

@export var range: float = 160.0
@export var retarget_interval: float = 0.2
@export var dir_step_deg: float = 22.5
@export var anim_prefix: String = "shoot_"
@export var anim_angle_offset: float = 90.0

@onready var body: AnimatedSprite2D = $Body

var target: Node = null
var _retarget_t: float = 0.0

func _ready() -> void:
	if body == null:
		push_error("Tower.gd: node 'Body' introuvable")
		return

	var default_anim := "%s0" % anim_prefix
	if body.sprite_frames and body.sprite_frames.has_animation(default_anim):
		body.play(default_anim)

	queue_redraw()

func _physics_process(delta: float) -> void:
	_retarget_t -= delta
	if _retarget_t <= 0.0 or not _is_valid_target(target):
		_retarget_t = retarget_interval
		target = _find_target()

	if _is_valid_target(target):
		_aim_at(target.global_position)

func _find_target() -> Node:
	var best: Node = null
	var best_d := range
	for e in get_tree().get_nodes_in_group("enemies"):
		if not _is_valid_target(e):
			continue
		var d := global_position.distance_to(e.global_position)
		if d <= range and d < best_d:
			best_d = d
			best = e
	return best

func _is_valid_target(e: Node) -> bool:
	return e != null and e.is_inside_tree()

func _aim_at(pos: Vector2) -> void:
	var dir := pos - global_position
	if dir.length() <= 0.001 or body == null:
		return

	var ang := rad_to_deg(atan2(dir.y, dir.x))
	if ang < 0.0:
		ang += 360.0

	ang = fmod(ang + anim_angle_offset + 360.0, 360.0)
	var steps := int(round(ang / dir_step_deg)) % int(360.0 / dir_step_deg)
	var snapped := int(steps * dir_step_deg)
	var anim_name := "%s%d" % [anim_prefix, snapped]

	if body.sprite_frames.has_animation(anim_name) and body.animation != anim_name:
		body.play(anim_name)

func _draw() -> void:
	
	# cercle rouge transparent
	draw_arc(Vector2.ZERO, range, 0, TAU, 64, Color(1, 0, 0))
