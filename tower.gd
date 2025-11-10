extends Node2D

@onready var body: AnimatedSprite2D = $Body
@onready var shadow: AnimatedSprite2D = $Shadow

func _ready() -> void:
	# Vérifie les ressources
	if not body or not shadow:
		push_error("Tower.gd: Body ou Shadow manquant.")
		return



	# Lancer l'animation idle si elle existe
	if body.sprite_frames.has_animation("idle"):
		body.play("idle")
	# Shadow joue la même anim s’il l’a aussi
	if shadow.sprite_frames and shadow.sprite_frames.has_animation("idle"):
		shadow.play("idle")
