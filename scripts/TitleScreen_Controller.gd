extends Control

func _ready() -> void:
	$UI/VBox/btnPlay.pressed.connect(_on_play_pressed)
	$UI/VBox/btnOptions.pressed.connect(_on_options_pressed)
	$UI/VBox/btnQuit.pressed.connect(_on_quit_pressed)

func _on_play_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/gameplay/Dungeon.tscn")

func _on_options_pressed() -> void:
	# De momento lo dejamos en placeholder
	print("Options pressed")

func _on_quit_pressed() -> void:
	get_tree().quit()
