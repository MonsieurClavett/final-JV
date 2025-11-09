extends PathFollow2D

@export var speed: float = 80.0
@export var max_health: int = 10
@export var health_decrease_rate: float = 1.0   # baisse de la vie par seconde

var health: float
var _last_global_pos: Vector2
var is_dead: bool = false

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var health_bar: ColorRect = $HealthBar


func _ready() -> void:
	_last_global_pos = global_position
	health = max_health
	if sprite:
		sprite.play("run_45")
	_update_health_bar()


func _process(delta: float) -> void:
	if is_dead:
		return  # on arrête tout pendant la mort

	# avance sur le chemin
	progress += speed * delta

	# baisse la vie graduellement
	health -= health_decrease_rate * delta
	health = clamp(health, 0.0, max_health)
	_update_health_bar()

	# change d'animation selon direction
	var current_pos = global_position
	var move = current_pos - _last_global_pos
	if move.length() > 0.1:
		_update_direction_animation(move)
	_last_global_pos = current_pos

	# mort ou fin du chemin
	if health <= 0.0:
		die()
	elif progress_ratio >= 1.0:
		queue_free()


func die() -> void:
	if is_dead:
		return
	is_dead = true

	# jouer anim death si elle existe
	if sprite.sprite_frames.has_animation("death"):
		sprite.play("death")
		# attendre la fin de l’anim avant de supprimer le loup
		sprite.animation_finished.connect(_on_death_anim_done, CONNECT_ONE_SHOT)
	else:
		queue_free()  # pas d'anim = on le supprime direct

	# cacher la barre de vie
	if health_bar:
		health_bar.hide()


func _on_death_anim_done() -> void:
	queue_free()


func _update_direction_animation(dir: Vector2) -> void:
	if is_dead:
		return

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
	if $AnimatedSprite2D.animation != anim_name \
	and $AnimatedSprite2D.sprite_frames.has_animation(anim_name):
		$AnimatedSprite2D.play(anim_name)


func _update_health_bar() -> void:
	if not health_bar:
		return
	var ratio = health / max_health
	health_bar.scale.x = ratio
	health_bar.color = Color(1.0 - ratio, ratio, 0.0)
