extends Node2D

# --- Scènes à assigner dans l’éditeur ---
@export var spider_scene: PackedScene
@export var spider_boss_scene: PackedScene
@export var tower_scene: PackedScene

@onready var path: Path2D = $Path2DPath
@onready var hud: CanvasLayer = $HUD

# --- timings (exemple) ---
@export var spider_spawn_time: float = 2.0   # à t=2s, 3 spiders
@export var boss_spawn_time: float = 10.0    # à t=10s, 1 boss

# --- état ---
var _elapsed: float = 0.0
var _spiders_spawned: bool = false
var _boss_spawned: bool = false

# 💰 or local (pas d'autoload)
var gold: int = 50


func _ready() -> void:
	if hud:
		hud.update_gold(gold)


func _process(delta: float) -> void:
	_elapsed += delta

	# 3 spiders une seule fois
	if not _spiders_spawned and _elapsed >= spider_spawn_time:
		_spiders_spawned = true
		for i in range(3):
			spawn_spider(i)

	# boss une seule fois
	if not _boss_spawned and _elapsed >= boss_spawn_time:
		_boss_spawned = true
		spawn_spider_boss()


# ---------- GOLD (local) ----------
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


# ---------- ACHAT TOUR (appelé par BuildButton) ----------
func try_buy_tower(cost: int, position: Vector2) -> bool:
	if tower_scene == null:
		push_error("world.gd: tower_scene non assignée")
		return false
	if not spend_gold(cost):
		print("Pas assez d'or (gold=%d, cost=%d)" % [gold, cost])
		return false

	var tower: Node2D = tower_scene.instantiate()
	add_child(tower)
	tower.global_position = position
	return true


# ---------- SPAWNERS ----------
func spawn_spider(offset_index: int = 0) -> void:
	if spider_scene == null:
		push_error("world.gd: spider_scene non assignée")
		return
	var s: Node = spider_scene.instantiate()
	path.add_child(s)
	# léger décalage pour éviter la superposition au départ
	if s is PathFollow2D:
		(s as PathFollow2D).progress = float(offset_index) * 40.0
	# passer la ref du monde pour les rewards
	if s.has_variable("world_ref"):
		s.world_ref = self
	else:
		s.set("world_ref", self)

func spawn_spider_boss() -> void:
	if spider_boss_scene == null:
		push_error("world.gd: spider_boss_scene non assignée")
		return
	var b: Node = spider_boss_scene.instantiate()
	path.add_child(b)
	if b is PathFollow2D:
		(b as PathFollow2D).progress = 0.0
	if b.has_variable("world_ref"):
		b.world_ref = self
	else:
		b.set("world_ref", self)
