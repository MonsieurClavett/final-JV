extends Node2D

@export var tower_scene: PackedScene
@export var spider_scene: PackedScene
@export var spider_boss_scene: PackedScene

@onready var hud: CanvasLayer = $HUD
@onready var path: Path2D = $Path2DPath

var gold: int = 500

# --- paramètres des vagues ---
@export var base_spiders_per_wave: int = 3            # nombre de spiders à la vague 1
@export var spiders_per_wave_increment: int = 1       # +1 spider par vague
@export var spawn_delay_between_spiders: float = 0.6  # délai entre chaque spider
@export var wave_rest_time: float = 3.0               # temps entre deux vagues
@export var boss_every: int = 3                       # boss toutes les 3 vagues (0 = jamais)

var wave_index: int = 0
var _time_until_next_wave: float = 1.0
var _is_spawning_wave: bool = false

var game_over_bool: bool = false

func _ready() -> void:
	if hud:
		hud.update_gold(gold)
		hud.update_wave(0)  # avant la première vague


func _process(delta: float) -> void:
	if _is_spawning_wave:
		return

	# si plus aucun ennemi vivant, on prépare la prochaine vague
	var enemies := get_tree().get_nodes_in_group("enemies")
	if enemies.size() == 0:
		_time_until_next_wave -= delta
		if _time_until_next_wave <= 0.0:
			_start_next_wave()


# ----------- gestion de l'or -----------
func add_gold(amount: int) -> void:
	if amount <= 0:
		return
	gold += amount
	if hud:
		hud.update_gold(gold)

func spend_gold(amount: int) -> bool:
	if gold < amount:
		return false
	gold -= amount
	if hud:
		hud.update_gold(gold)
	return true


# ----------- achat de tour -----------
func try_buy_tower(cost: int, world_pos: Vector2) -> bool:
	if tower_scene == null:
		push_error("world.gd: tower_scene non assignée")
		return false
	if gold < cost:
		print("Pas assez d'or (gold=%d, cost=%d)" % [gold, cost])
		return false

	if not spend_gold(cost):
		return false

	var tower := tower_scene.instantiate()
	add_child(tower)
	tower.global_position = world_pos

	# passe la ref du monde à la tour si elle a init(world)
	if tower.has_method("init"):
		tower.init(self)

	return true


# ----------- spawn d'ennemis -----------
func spawn_spider() -> void:
	if spider_scene == null:
		push_error("world.gd: spider_scene non assignée")
		return

	var s := spider_scene.instantiate()
	path.add_child(s)
	if s is PathFollow2D:
		(s as PathFollow2D).progress = 0.0

	# passe world_ref si le script de l'araignée en a besoin
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


# ----------- vagues infinies -----------
func _start_next_wave() -> void:
	_is_spawning_wave = true
	wave_index += 1

	if hud:
		hud.update_wave(wave_index)

	_spawn_wave_for_index(wave_index)


func _spawn_wave_for_index(wave: int) -> void:
	# on lance la coroutine dans un call_deferred pour éviter les soucis dans _process
	call_deferred("_spawn_wave_for_index_impl", wave)


func _spawn_wave_for_index_impl(wave: int) -> void:
	# nombre de spiders qui augmente avec la vague
	var spiders_to_spawn: int = base_spiders_per_wave + (wave - 1) * spiders_per_wave_increment

	for i in range(spiders_to_spawn):
		spawn_spider()
		if i < spiders_to_spawn - 1:
			await get_tree().create_timer(spawn_delay_between_spiders).timeout

	# boss toutes les X vagues
	if boss_every > 0 and wave % boss_every == 0:
		await get_tree().create_timer(2.0).timeout
		spawn_spider_boss()

	# prépare la prochaine vague
	_time_until_next_wave = wave_rest_time
	_is_spawning_wave = false
	
func game_over() -> void:
	if game_over_bool:
		return
	game_over_bool = true

	print("World: GAME OVER")

	if hud and hud.has_method("show_game_over"):
		hud.show_game_over()

	get_tree().paused = true
