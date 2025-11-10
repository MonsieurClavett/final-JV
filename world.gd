# world.gd
extends Node2D

@export var wolf_scene: PackedScene

@onready var path: Path2D = $Path2DPath
@onready var hud: CanvasLayer = $HUD

@export var spawn_interval: float = 1.5
var _timer: float = 0.0

var gold: int = 0


func _ready() -> void:
	if hud == null:
		push_error("HUD node not found as $HUD")
	else:
		hud.update_gold(gold)


func _process(delta: float) -> void:
	_timer -= delta
	if _timer <= 0.0:
		_timer = spawn_interval
		spawn_wolf()


func spawn_wolf() -> void:
	if wolf_scene == null:
		push_error("wolf_scene not set in world.gd")
		return

	var wolf = wolf_scene.instantiate()
	path.add_child(wolf)
	wolf.progress = 0.0
	wolf.world_ref = self  # on donne la ref du monde


func add_gold(amount: int) -> void:
	if amount <= 0:
		return

	gold += amount
	if hud:
		hud.update_gold(gold)
