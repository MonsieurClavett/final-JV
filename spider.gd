extends PathFollow2D

@export var speed: float = 80.0
@export var reward: int = 10

var health: float = 10.0          # adapte à ton jeu
var world_ref: Node = null

func _ready() -> void:
	add_to_group("enemies")        # utile si ta tour cible par groupe

func _process(delta: float) -> void:
	# avance sur le chemin
	progress += speed * delta

	# (option test) baisse de vie automatique pour vérifier les rewards
	# enlève ce bloc quand tu auras le vrai système de dégâts
	health -= delta * 2.0
	if health <= 0.0:
		die()

	# supprime à la fin du chemin
	if progress_ratio >= 1.0:
		queue_free()

func take_damage(amount: float) -> void:
	health -= amount
	if health <= 0.0:
		die()

func die() -> void:
	if world_ref:
		world_ref.add_gold(reward)
	queue_free()
