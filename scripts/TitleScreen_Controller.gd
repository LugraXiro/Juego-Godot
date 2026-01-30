
extends Control

# ====== REFERENCIAS A NODOS ======
@onready var btn_jugar: BaseButton = $BtnJugar
@onready var btn_ajustes: BaseButton = $BtnAjustes

# Popup de opciones
@onready var popup: Control = $OptionsPopup
@onready var dimmer: ColorRect = $OptionsPopup/Dimmer

# Iconos que cambian para mostrar estado ON/OFF
@onready var icon_music: TextureRect = $OptionsPopup/IconMusic
@onready var icon_sfx: TextureRect = $OptionsPopup/IconSfx

# Botones dentro del popup
@onready var btn_sfx: BaseButton = $OptionsPopup/BtnSfx
@onready var btn_music: BaseButton = $OptionsPopup/BtnMusic
@onready var btn_salir: BaseButton = $OptionsPopup/BtnSalir

# Audio de SFX
@onready var ui_hover_player: AudioStreamPlayer = $UiHoverPlayer

# Audio de Musica
@onready var music_player: AudioStreamPlayer = $MusicPlayer
# ====== RUTAS DE LOS ICONOS ======
const ICO_MUSIC_ON := "res://assets/sprites/UI_images/UI_TitleScreenOptions_ICO_Musica_Activado.png"
const ICO_MUSIC_OFF := "res://assets/sprites/UI_images/UI_TitleScreenOptions_ICO_Musica_Desactivado.png"
const ICO_SFX_ON := "res://assets/sprites/UI_images/UI_TitleScreenOptions_ICO_Sonido_Activado.png"
const ICO_SFX_OFF := "res://assets/sprites/UI_images/UI_TitleScreenOptions_ICO_Sonido_Desactivado.png"

# ====== ESTADO DE AUDIO ======
var music_on: bool = true
var sfx_on: bool = true

# ====== PERSISTENCIA DE CONFIGURACIÓN ======
const SETTINGS_PATH := "user://settings.cfg"

func _ready() -> void:
	# El popup debe estar invisible al inicio
	popup.visible = false
	
	# Conectar botones del menú principal
	btn_jugar.pressed.connect(_on_jugar_pressed)
	btn_ajustes.pressed.connect(_on_ajustes_pressed)
	
	# Conectar botones del popup de opciones
	btn_music.pressed.connect(_on_toggle_music)
	btn_sfx.pressed.connect(_on_toggle_sfx)
	btn_salir.pressed.connect(_on_close_options)
	
	# Permitir cerrar el popup haciendo clic en el dimmer (fondo oscuro)
	dimmer.gui_input.connect(_on_dimmer_gui_input)
	
	# Conectar efectos de hover para todos los botones
	_connect_hover(btn_jugar)
	_connect_hover(btn_ajustes)
	_connect_hover(btn_music)
	_connect_hover(btn_sfx)
	_connect_hover(btn_salir)
	
	sfx_on = true
	music_player.play()
	music_player.finished.connect(func(): music_player.play())
	_apply_audio_states()
	
	# Cargar configuración guardada (si existe)
	_load_settings()
	
	# Aplicar el estado de audio
	_apply_audio_states()
	
	# Actualizar los iconos según el estado actual
	_refresh_icons()

# ====== FUNCIONES DE BOTONES DEL MENÚ PRINCIPAL ======

func _on_jugar_pressed() -> void:
	# Cambia a la escena de juego
	get_tree().change_scene_to_file("res://scenes/gameplay/Dungeon.tscn")

func _on_ajustes_pressed() -> void:
	# Mostrar el popup de opciones
	popup.visible = true

# ====== FUNCIONES DE BOTONES DEL POPUP ======

func _on_close_options() -> void:
	# Ocultar el popup de opciones (volver al menú principal)
	popup.visible = false

func _on_toggle_music() -> void:
	# Alternar el estado de la música
	music_on = not music_on
	
	# Aplicar el cambio al sistema de audio
	_apply_audio_states()
	
	# Actualizar el icono visual
	_refresh_icons()
	
	# Guardar la configuración
	_save_settings()

func _on_toggle_sfx() -> void:
	# Alternar el estado del sonido
	sfx_on = not sfx_on
	
	# Aplicar el cambio al sistema de audio
	_apply_audio_states()
	
	# Actualizar el icono visual
	_refresh_icons()
	
	# Guardar la configuración
	_save_settings()

# ====== FUNCIONES AUXILIARES ======

func _apply_audio_states() -> void:
	"""
	Aplica el estado ON/OFF a los buses de audio.
	Si los buses no existen todavía, no hace nada (no da error).
	"""
	# Buscar el bus de música
	var music_idx := AudioServer.get_bus_index("Music")
	if music_idx != -1:
		# Mutear si music_on es false
		AudioServer.set_bus_mute(music_idx, not music_on)
	
	# Buscar el bus de efectos de sonido
	var sfx_idx := AudioServer.get_bus_index("SFX")
	if sfx_idx != -1:
		# Mutear si sfx_on es false
		AudioServer.set_bus_mute(sfx_idx, not sfx_on)

func _refresh_icons() -> void:
	"""
	Actualiza la textura de los iconos según el estado actual.
	Esto es lo que proporciona feedback visual al usuario.
	"""
	# Cargar la imagen correspondiente para música
	var music_path := ICO_MUSIC_ON if music_on else ICO_MUSIC_OFF
	var music_texture := load(music_path) as Texture2D
	if music_texture:
		icon_music.texture = music_texture
	else:
		push_warning("No se pudo cargar la textura: " + music_path)
	
	# Cargar la imagen correspondiente para sonido
	var sfx_path := ICO_SFX_ON if sfx_on else ICO_SFX_OFF
	var sfx_texture := load(sfx_path) as Texture2D
	if sfx_texture:
		icon_sfx.texture = sfx_texture
	else:
		push_warning("No se pudo cargar la textura: " + sfx_path)

func _on_dimmer_gui_input(event: InputEvent) -> void:
	"""
	Permite cerrar el popup haciendo clic en el fondo oscuro (dimmer).
	"""
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			_on_close_options()

# ====== SISTEMA DE HOVER SOUND ======

func _connect_hover(btn: Control) -> void:
	"""
	Conecta el sonido de hover a un botón.
	Se reproduce cuando el mouse entra en el área del botón.
	"""
	if btn:
		btn.mouse_entered.connect(_on_any_button_hover)
		# También puedes conectar focus_entered si usas navegación por teclado:
		# btn.focus_entered.connect(_on_any_button_hover)

func _on_any_button_hover() -> void:
	print("HOVER")
	"""
	Reproduce el sonido de hover cuando el mouse pasa por encima de un botón.
	"""
	if $UIHoverPlayer and $UIHoverPlayer.stream:
		# Reinicia si entra muy rápido de un botón a otro
		$UIHoverPlayer.stop()
		$UIHoverPlayer.play()

# ====== PERSISTENCIA ======

func _save_settings() -> void:
	"""
	Guarda la configuración de audio en un archivo.
	Así se recuerdan las preferencias entre sesiones.
	"""
	var cfg := ConfigFile.new()
	cfg.set_value("audio", "music_on", music_on)
	cfg.set_value("audio", "sfx_on", sfx_on)
	var error := cfg.save(SETTINGS_PATH)
	if error != OK:
		push_warning("No se pudo guardar la configuración: " + str(error))

func _load_settings() -> void:
	"""
	Carga la configuración guardada (si existe).
	Si no existe el archivo, usa los valores predeterminados (ambos activados).
	"""
	var cfg := ConfigFile.new()
	var error := cfg.load(SETTINGS_PATH)
	if error == OK:
		music_on = bool(cfg.get_value("audio", "music_on", true))
		sfx_on = bool(cfg.get_value("audio", "sfx_on", true))
