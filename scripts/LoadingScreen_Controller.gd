extends Control

@onready var loading_bar: TextureRect = $LoadingBar
@onready var timer: Timer = $Timer

var bar_textures: Array[Texture2D] = []
var current_step: int = 0

func _ready() -> void:
	bar_textures = [
		preload("res://assets/sprites/UI_images/UI_LoadingScreen_BAR_Progress_01.PNG"),
		preload("res://assets/sprites/UI_images/UI_LoadingScreen_BAR_Progress_02.PNG"),
		preload("res://assets/sprites/UI_images/UI_LoadingScreen_BAR_Progress_03.PNG"),
		preload("res://assets/sprites/UI_images/UI_LoadingScreen_BAR_Progress_04.PNG")
	]

	loading_bar.texture = bar_textures[0]

	# En 4.5.1 puedes conectar por editor o por código:
	if not timer.timeout.is_connected(_on_timer_timeout):
		timer.timeout.connect(_on_timer_timeout)

func _on_timer_timeout() -> void:
	print("timeout", current_step)
	current_step += 1

	if current_step < bar_textures.size():
		loading_bar.texture = bar_textures[current_step]
	else:
		timer.stop()
		get_tree().change_scene_to_file("res://scenes/SCN_TitleScreen.tscn")
