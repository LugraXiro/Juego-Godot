extends Control

# ====== BOTONES MENU (según tu escena) ======
@onready var btn_jugar: BaseButton = $BtnJugar
@onready var btn_ajustes: BaseButton = $BtnAjustes

# ====== POPUP OPCIONES ======
@onready var popup: Control = $OptionsPopup
@onready var dimmer: ColorRect = $OptionsPopup/Dimmer

@onready var icon_music: TextureRect = $OptionsPopup/IconMusic
@onready var icon_sfx: TextureRect = $OptionsPopup/IconSfx

@onready var btn_sfx: BaseButton = $OptionsPopup/BtnSfx
@onready var btn_music: BaseButton = $OptionsPopup/BtnMusic
@onready var btn_salir: BaseButton = $OptionsPopup/BtnSalir

# ====== RUTAS ICONOS (pega aquí Copy Path exacto) ======
const ICO_MUSIC_ON := "res://assets/sprites/UI_images/UI_TitleScreenOptions_ICO_Musica_Activado.png"
const ICO_MUSIC_OFF := "res://assets/sprites/UI_images/UI_TitleScreenOptions_ICO_Musica_Desactivado.png"
const ICO_SFX_ON := "res://assets/sprites/UI_images/UI_TitleScreenOptions_ICO_Sonido_Activado.png"
const ICO_SFX_OFF := "res://assets/sprites/UI_images/UI_TitleScreenOptions_ICO_Sonido_Desactivado.png"

# ====== ESTADO ======
var music_on: bool = true
var sfx_on: bool = true

# (Opcional) guardar ajustes
const SETTINGS_PATH := "user://settings.cfg"

func _ready() -> void:
	print("TitleScreen READY") # luego lo puedes borrar

	# Asegura que empieza cerrado
	popup.visible = false

	# Conectar botones del menú
	btn_jugar.pressed.connect(_on_jugar_pressed)
	btn_ajustes.pressed.connect(_on_ajustes_pressed)

	# Conectar botones del popup
	btn_music.pressed.connect(_on_toggle_music)
	btn_sfx.pressed.connect(_on_toggle_sfx)
	btn_salir.pressed.connect(_on_close_options)

	# Cerrar al click fuera
	dimmer.gui_input.connect(_on_dimmer_gui_input)

	_load_settings()
	_apply_audio_states()
	_refresh_icons()

func _on_jugar_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/gameplay/Dungeon.tscn")

func _on_ajustes_pressed() -> void:
	popup.visible = true

func _on_close_options() -> void:
	popup.visible = false

func _on_toggle_music() -> void:
	print("toggle music") # luego lo borras
	music_on = not music_on
	_apply_audio_states()
	_refresh_icons()
	_save_settings()

func _on_toggle_sfx() -> void:
	print("toggle sfx") # luego lo borras
	sfx_on = not sfx_on
	_apply_audio_states()
	_refresh_icons()
	_save_settings()

func _apply_audio_states() -> void:
	# Si todavía no tienes buses, no pasa nada: simplemente no mutea.
	var music_idx := AudioServer.get_bus_index("Music")
	if music_idx != -1:
		AudioServer.set_bus_mute(music_idx, not music_on)

	var sfx_idx := AudioServer.get_bus_index("SFX")
	if sfx_idx != -1:
		AudioServer.set_bus_mute(sfx_idx, not sfx_on)

func _refresh_icons() -> void:
	icon_music.texture = load(ICO_MUSIC_ON if music_on else ICO_MUSIC_OFF) as Texture2D
	icon_sfx.texture = load(ICO_SFX_ON if sfx_on else ICO_SFX_OFF) as Texture2D

func _on_dimmer_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_on_close_options()

func _save_settings() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "music_on", music_on)
	cfg.set_value("audio", "sfx_on", sfx_on)
	cfg.save(SETTINGS_PATH)

func _load_settings() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(SETTINGS_PATH) == OK:
		music_on = bool(cfg.get_value("audio", "music_on", true))
		sfx_on = bool(cfg.get_value("audio", "sfx_on", true))
