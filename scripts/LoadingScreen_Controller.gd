extends Control

@export var next_scene_path: String = "res://scenes/SCN_TitleScreen.tscn"
@export var loading_anim_name: String = "new_animation"
@export var shoot_anim_name: String = "shoot_sequence"
@export var sync_timer_to_loading_anim: bool = true

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer

@onready var dimmer: ColorRect = $ColorRect
@onready var loading_bar: TextureRect = $LoadingBar

@onready var puerta_cerrada: TextureRect = $BgHolder/PuertaCerrada
@onready var puerta_rota: TextureRect = $BgHolder/PuertaRota

@onready var gun: TextureRect = $Gun
@onready var explosion: TextureRect = $Explosion
@onready var shot_sfx: AudioStreamPlayer = $ShotSfx
@onready var press_to_continue: Label = $PressToContinue

var can_continue := false
var started_cinematic := false

func _ready() -> void:
	# Estado inicial
	can_continue = false
	started_cinematic = false

	puerta_cerrada.visible = true
	puerta_rota.visible = false

	loading_bar.modulate.a = 1.0
	dimmer.modulate.a = 1.0

	gun.modulate.a = 0.0
	explosion.modulate.a = 0.0

	press_to_continue.visible = false
	press_to_continue.modulate.a = 1.0

	timer.one_shot = true
	timer.timeout.connect(_on_loading_finished)

	if sync_timer_to_loading_anim and anim.has_animation(loading_anim_name):
		timer.wait_time = anim.get_animation(loading_anim_name).length

	if anim.has_animation(loading_anim_name):
		anim.play(loading_anim_name)

	timer.start()

func _on_loading_finished() -> void:
	can_continue = true
	press_to_continue.visible = true

func play_shot_sfx() -> void:
	if shot_sfx and shot_sfx.stream:
		shot_sfx.stop()
		shot_sfx.play()

# Mejor que _unhandled_input para pantallas UI
func _input(event: InputEvent) -> void:
	if not can_continue or started_cinematic:
		return

	if event is InputEventKey and event.pressed and not event.echo:
		started_cinematic = true
		can_continue = false
		press_to_continue.visible = false

		if anim.has_animation(shoot_anim_name):
			anim.play(shoot_anim_name)

func break_door() -> void:
	puerta_cerrada.visible = false
	puerta_rota.visible = true

func go_to_next_scene() -> void:
	get_tree().change_scene_to_file(next_scene_path)
