extends Node2D

@export var projectile_scene: PackedScene
@export var fire_rate: float = 200.0
var cooldown: float = 0.0

@export var range: float = 160.0
@export var retarget_interval: float = 0.2
@export var dir_step_deg: float = 22.5
@export var anim_prefix: String = "shoot_"
@export var anim_angle_offset: float = 90.0   # adapte selon ton sprite

@onready var body: AnimatedSprite2D = $Body

var target: Node2D = null
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
	if body == null:
		return

	cooldown -= delta
	_retarget_t -= delta

	# (re)cibler périodiquement
	if _retarget_t <= 0.0 or not _is_valid_target(target):
		_retarget_t = retarget_interval
		target = _find_target()

	if _is_valid_target(target):
		_aim_at(target.global_position)
		if cooldown <= 0.0:
			_shoot()
			cooldown = 1.0 / fire_rate


func _find_target() -> Node2D:
	var enemies: Array = get_tree().get_nodes_in_group("enemies")
	var closest: Node2D = null
	var best_dist: float = range

	for e in enemies:
		if not (e is Node2D):
			continue
		var enemy := e as Node2D
		var dist: float = global_position.distance_to(enemy.global_position)
		if dist < best_dist:
			best_dist = dist
			closest = enemy

	return closest


func _shoot() -> void:
	if projectile_scene == null or target == null:
		return

	var p: Node2D = projectile_scene.instantiate()
	get_tree().current_scene.add_child(p)
	p.global_position = global_position

	# passe la cible au projectile
	if "target" in p:
		p.target = target


func _is_valid_target(e) -> bool:
	if e == null:
		return false
	if not is_instance_valid(e):
		return false
	if not (e is Node2D):
		return false
	return e.is_inside_tree()



func _aim_at(pos: Vector2) -> void:
	var dir: Vector2 = pos - global_position
	if dir.length() <= 0.001:
		return

	var ang: float = rad_to_deg(atan2(dir.y, dir.x))
	if ang < 0.0:
		ang += 360.0

	ang = fmod(ang + anim_angle_offset + 360.0, 360.0)

	var step_count: int = int(360.0 / dir_step_deg)
	var step_idx: int = int(round(ang / dir_step_deg)) % step_count
	var snapped_deg: int = int(step_idx * dir_step_deg)

	var anim_name := "%s%d" % [anim_prefix, snapped_deg]

	if body.sprite_frames.has_animation(anim_name) and body.animation != anim_name:
		body.play(anim_name)


func _draw() -> void:
	# cercle de portée (arc rouge)
	draw_arc(Vector2.ZERO, range, 0, TAU, 64, Color(1, 0, 0))
