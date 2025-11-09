extends Node2D

@export var wolf_scene: PackedScene
@onready var path: Path2D = $Path2DPath

@export var spawn_interval: float = 1.5
var _timer: float = 0.0

func _ready() -> void:
	_timer = spawn_interval
	if path == null:
		push_error("Path2DPath introuvable dans la scène world.")
	if wolf_scene == null:
		push_error("wolf_scene n'est pas assigné dans l'inspecteur !")

func _process(delta: float) -> void:
	_timer -= delta
	if _timer <= 0.0:
		_timer = spawn_interval
		spawn_wolf()

func spawn_wolf() -> void:
	if wolf_scene == null or path == null:
		return

	var wolf = wolf_scene.instantiate()
	if wolf == null:
		push_error("Échec instantiate wolf_scene")
		return

	path.add_child(wolf)
	wolf.progress = 0.0
	print("Spawn wolf at progress 0")
