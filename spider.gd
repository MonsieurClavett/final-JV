extends PathFollow2D

@export var speed: float = 60.0
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

	add_to_group("enemies")  # pour que la tour puisse la cibler

	# mémorise la largeur initiale de la barre de vie
	if health_bar_fg:
		_health_bar_full_width = health_bar_fg.size.x
		if _health_bar_full_width <= 0.0:
			_health_bar_full_width = 40.0

	_update_health_bar()

	# anim de base
	if body and body.sprite_frames.has_animation("run_0"):
		body.play("run_0")
	if shadow and shadow.sprite_frames.has_animation("run_0"):
		shadow.play("run_0")


func _process(delta: float) -> void:
	if is_dying:
		return  # ne plus bouger si en train de mourir

	# avance sur le chemin
	progress += speed * delta

	var current_pos: Vector2 = global_position
	var move: Vector2 = current_pos - _last_global_pos
	if move.length() > 0.1:
		_update_direction_animation(move)
	_last_global_pos = current_pos

	# Fin du chemin → tu pourras mettre des dégâts au joueur plus tard
	if progress_ratio >= 1.0:
		queue_free()


# --- dégâts depuis les projectiles ---
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

	# donner le gold tout de suite si world_ref est branché
	if world_ref and world_ref.has_method("add_gold"):
		world_ref.add_gold(reward)

	var has_death_anim: bool = false

	# animation de mort du body
	if body and body.sprite_frames.has_animation("death"):
		body.play("death")
		has_death_anim = true

	# animation de mort de l'ombre (même nom "death", change si besoin)
	if shadow and shadow.sprite_frames and shadow.sprite_frames.has_animation("death"):
		shadow.play("death")

	if has_death_anim:
		await body.animation_finished

	queue_free()


# --- direction / anim de course ---
func _update_direction_animation(dir: Vector2) -> void:
	if body == null:
		return

	var angle: float = rad_to_deg(atan2(dir.y, dir.x))
	if angle < 0.0:
		angle += 360.0

	# 8 directions : 0, 45, 90, ..., 315
	var step: float = 45.0
	var index: int = int(round(angle / step)) % 8
	var snapped_angle: int = index * int(step)
	var anim_name := "run_%d" % snapped_angle

	if body.sprite_frames.has_animation(anim_name) and body.animation != anim_name:
		body.play(anim_name)
	if shadow and shadow.sprite_frames.has_animation(anim_name) and shadow.animation != anim_name:
		shadow.play(anim_name)


# --- health bar ---
func _update_health_bar() -> void:
	if health_bar_fg == null:
		return

	var ratio: float = 0.0
	if max_health > 0.0:
		ratio = clamp(health / max_health, 0.0, 1.0)

	var full_width: float = _health_bar_full_width
	health_bar_fg.size.x = full_width * ratio

	# vert → rouge
	var color: Color = Color(1.0 - ratio, ratio, 0.0)
	health_bar_fg.color = color
