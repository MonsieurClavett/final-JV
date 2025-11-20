extends Node2D

@export var tower_scene: PackedScene
@export var spider_scene: PackedScene
@export var spider_boss_scene: PackedScene

@onready var hud: CanvasLayer = $HUD
@onready var path: Path2D = $Path2DPath

var gold: int = 500  


func _ready() -> void:
	if hud:
		hud.update_gold(gold)
	spawn_spider_wave_then_boss(3, 1.0)


func try_buy_tower(cost: int, world_pos: Vector2) -> bool:
	if tower_scene == null:
		push_error("world.gd: tower_scene non assignée")
		return false
	if gold < cost:
		print("Pas assez d'or (gold=%d, cost=%d)" % [gold, cost])
		return false

	gold -= cost
	if hud:
		hud.update_gold(gold)

	var tower := tower_scene.instantiate()
	add_child(tower)
	tower.global_position = world_pos
	return true

func spawn_spider() -> void:
	if spider_scene == null:
		push_error("world.gd: spider_scene non assignée")
		return

	var s := spider_scene.instantiate()
	path.add_child(s)
	if s is PathFollow2D:
		(s as PathFollow2D).progress = 0.0

	if "world_ref" in s:
		s.world_ref = self


func spawn_spider_boss() -> void:
	if spider_boss_scene == null:
		push_error("world.gd: spider_boss_scene non assignée")
		return

	var b := spider_boss_scene.instantiate()
	path.add_child(b)
	if b is PathFollow2D:
		(b as PathFollow2D).progress = 0.0

	if "world_ref" in b:
		b.world_ref = self



func spawn_spider_wave_then_boss(count: int, delay_sec: float) -> void:
	call_deferred("_spawn_wave_then_boss_impl", count, delay_sec)

func _spawn_wave_then_boss_impl(count: int, delay_sec: float) -> void:
	for i in range(count):
		spawn_spider()
		if i < count - 1:
			await get_tree().create_timer(delay_sec).timeout
	await get_tree().create_timer(3).timeout
	spawn_spider_boss()
	
func add_gold(amount: int) -> void:
	if amount <= 0:
		return
	gold += amount
	if hud:
		hud.update_gold(gold)
