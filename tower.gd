extends Node2D

@export var upgrade_colors: PackedColorArray = PackedColorArray([
	Color(1, 1, 1),          # niveau 1 (normal)
	Color(0.6, 0.8, 1.0),    # niveau 2 (bleu)
	Color(0.981, 0.478, 1.0, 1.0)     # niveau 3 (mauve)
])


@export var projectile_scene: PackedScene
@export var fire_rate: float = 2.0
var cooldown: float = 0.0


@export var range: float = 200.0
@export var retarget_interval: float = 0.2
@export var dir_step_deg: float = 22.5
@export var anim_prefix: String = "shoot_"
@export var anim_angle_offset: float = 90.0

# --- UPGRADES ---
@export var upgrade_button_scene: PackedScene
@export var upgrade_costs: PackedInt32Array = PackedInt32Array([100, 200])

var upgrade_index: int = 0
var world_ref: Node = null
var upgrade_button_ref: Button = null

@onready var body: AnimatedSprite2D = $Body
@onready var shadow: AnimatedSprite2D = $Shadow


var target: Node2D = null
var _retarget_t: float = 0.0


func _ready() -> void:
	if body == null:
		push_error("Tower.gd: node 'Body' introuvable")
		return

	var default_anim := "%s0" % anim_prefix
	if body.sprite_frames and body.sprite_frames.has_animation(default_anim):
		body.play(default_anim)
		
	_apply_upgrade_color()


# appelé par World après placement
func init(world: Node) -> void:
	world_ref = world
	_spawn_upgrade_button()


func _physics_process(delta: float) -> void:
	cooldown -= delta
	_retarget_t -= delta

	if not _is_valid_target(target):
		target = null

	if _retarget_t <= 0.0 or target == null:
		_retarget_t = retarget_interval
		target = _find_target()

	if target:
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
	if "target" in p:
		p.target = target


func _is_valid_target(e) -> bool:
	return e != null and is_instance_valid(e) and e.is_inside_tree()


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


# ---------- UPGRADE ----------
func get_current_upgrade_cost() -> int:
	if upgrade_index >= upgrade_costs.size():
		return 0
	return upgrade_costs[upgrade_index]


func try_upgrade(world: Node) -> bool:
	var cost: int = get_current_upgrade_cost()
	if cost <= 0:
		return false

	if world == null or not world.has_method("spend_gold"):
		push_error("Tower: world invalide ou pas spend_gold()")
		return false

	var ok: bool = world.spend_gold(cost)
	if not ok:
		print("Pas assez d'or pour upgrade")
		return false

	# 🔥 upgrade: double fire_rate
	fire_rate *= 3.0
	upgrade_index += 1
	_apply_upgrade_color()

	print("✅ Upgrade OK. fire_rate =", fire_rate, "next cost =", get_current_upgrade_cost())
	return true


func _spawn_upgrade_button() -> void:
	if upgrade_button_scene == null or world_ref == null:
		return

	var btn: Button = upgrade_button_scene.instantiate()
	add_child(btn)
	btn.position = Vector2(0, 25)
	btn.z_index = 100

	upgrade_button_ref = btn

	if btn.has_method("setup"):
		btn.setup(self, world_ref)
		
func _apply_upgrade_color() -> void:
	var idx: int = clampi(upgrade_index, 0, upgrade_colors.size() - 1)
	var c: Color = upgrade_colors[idx]

	if body:
		body.modulate = c

	# optionnel : ombre un peu plus visible avec le level
	if shadow:
		shadow.modulate = Color(1, 1, 1, 0.6)
