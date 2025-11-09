# world.gd
extends Node2D

@export var wolf_scene: PackedScene
@export var spider_scene: PackedScene
@onready var path: Path2D = $Path2DPath

@export var spawn_interval: float = 1.5  # secondes
var _timer: float = 0.0

func _process(delta: float) -> void:
	_timer -= delta
	if _timer <= 0.0:
		_timer = spawn_interval
		spawn_enemy()

func spawn_enemy() -> void:
	var enemy: PathFollow2D

	# 50/50 chance entre un loup et une araignée
	if randf() < 0.5:
		enemy = wolf_scene.instantiate()
	else:
		enemy = spider_scene.instantiate()

	path.add_child(enemy)
	enemy.progress = 0.0
