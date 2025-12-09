extends Node

var save_file_path := "user://save/"
var save_file_name := "GameSave.tres"

var data: GameData = GameData.new()


func _ready() -> void:
	# s’assure que le dossier existe
	DirAccess.make_dir_absolute(save_file_path)
	_load_game()


func _load_game() -> void:
	var full_path := save_file_path + save_file_name

	if FileAccess.file_exists(full_path):
		var res := ResourceLoader.load(full_path)
		if res:
			data = res.duplicate(true) as GameData
		else:
			data = GameData.new()
	else:
		# première fois : on crée un fichier de base
		data = GameData.new()
		_save_game()


func _save_game() -> void:
	var full_path := save_file_path + save_file_name
	ResourceSaver.save(data, full_path)


func update_highest_wave(current_wave: int) -> void:
	if current_wave > data.highest_wave:
		data.highest_wave = current_wave
		_save_game()
