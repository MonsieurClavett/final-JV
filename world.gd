extends Node2D

@export var tower_scene: PackedScene
@export var spider_scene: PackedScene
@export var spider_boss_scene: PackedScene
@onready var pause_menu: CanvasLayer = $PauseMenu


@onready var hud: CanvasLayer = $HUD
@onready var path: Path2D = $Path2DPath

var save_path := "user://GameSave.tres"

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
var debug_mode: bool = false

var game_over_bool: bool = false

var shop_buttons: Array[Button] = []
var shop_index: int = 0


func _ready() -> void:
	_init_shop_buttons()

	if hud:
		hud.update_gold(gold)
		hud.update_wave(0)  # avant la première vague

func _init_shop_buttons() -> void:
	shop_buttons.clear()
	_collect_shop_buttons(self)
	_cleanup_shop_buttons()

	if shop_buttons.is_empty():
		shop_index = 0
		return

	shop_index = clampi(shop_index, 0, shop_buttons.size() - 1)
	shop_buttons[shop_index].grab_focus()
	
func _collect_shop_buttons(node: Node) -> void:
	for child in node.get_children():
		if child is Button:
			var btn := child as Button
			# On prend les BuildButton (root) ET les UpgradeButton (dans les tours)
			if btn.name.begins_with("BuildButton") or btn.name.begins_with("UpgradeButton"):
				btn.focus_mode = Control.FOCUS_ALL
				shop_buttons.append(btn)
		_collect_shop_buttons(child)

		
func _cleanup_shop_buttons() -> void:
	for i in range(shop_buttons.size() - 1, -1, -1):
		var btn := shop_buttons[i]
		if btn == null or not is_instance_valid(btn) or not btn.is_inside_tree():
			shop_buttons.remove_at(i)

	if shop_buttons.is_empty():
		shop_index = 0
	else:
		shop_index = clamp(shop_index, 0, shop_buttons.size() - 1)
	
func refresh_shop_buttons() -> void:
	_init_shop_buttons()


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
		
	call_deferred("refresh_shop_buttons")

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

	_save_highest_wave()

	if hud and hud.has_method("show_game_over"):
		hud.show_game_over()

	get_tree().paused = true
	


	
func _input(event: InputEvent) -> void:
	# 🔹 Debug (touche debug_toggle)
	if event.is_action_pressed("debug_toggle"):
		debug_mode = not debug_mode
		_apply_debug_mode()
		return

	# 🔹 Pause (touche pause_menu / ESC)
	if event.is_action_pressed("pause_menu") and not game_over_bool:
		if pause_menu:
			pause_menu.toggle_menu()
		return

	# 🔹 Si le jeu est en game over : on ne gère plus le shop
	if game_over_bool:
		return

	# 🔹 Navigation dans les boutons shop (build/upgrade)
	if event.is_action_pressed("ui_left"):
		_move_shop_focus(-1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_right"):
		_move_shop_focus(1)
		get_viewport().set_input_as_handled()



		
func _activate_current_shop_button() -> void:
	_cleanup_shop_buttons()
	if shop_buttons.is_empty():
		return

	var btn := shop_buttons[shop_index]
	btn.emit_signal("pressed")


func _move_shop_focus(dir: int) -> void:
	_cleanup_shop_buttons()
	if shop_buttons.is_empty():
		return

	shop_index = posmod(shop_index + dir, shop_buttons.size())
	var btn := shop_buttons[shop_index]
	btn.grab_focus()
		
func _apply_debug_mode() -> void:
	get_tree().debug_collisions_hint = debug_mode

	if hud and hud.has_method("set_debug_mode"):
		hud.set_debug_mode(debug_mode)

	if has_node("DebugVectors"):
		$DebugVectors.enabled = debug_mode

	# ⬇️ activer le mode debug sur toutes les tours
	var towers = get_tree().get_nodes_in_group("towers")
	for t in towers:
		if "debug_enabled" in t:
			t.debug_enabled = debug_mode
			t.queue_redraw()
			
func _save_highest_wave() -> void:
	var data: GameData

	# si un fichier existe déjà → on le charge
	if FileAccess.file_exists(save_path):
		var loaded = ResourceLoader.load(save_path)
		if loaded:
			data = loaded.duplicate(true)
		else:
			data = GameData.new()
	else:
		data = GameData.new()

	# si la vague courante est meilleure → sauvegarde
	if wave_index > data.highest_wave:
		data.highest_wave = wave_index
		ResourceSaver.save(data, save_path)
		print("🎉 Nouveau record sauvegardé :", wave_index)
	else:
		print("Record non battu. Record actuel :", data.highest_wave)
