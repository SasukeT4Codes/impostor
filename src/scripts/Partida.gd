extends Control

# --- Referencias a nodos ---
@onready var timer := $MenuVBox/Titulo/Timer
@onready var tiempo_label := $MenuVBox/Titulo/Label
@onready var imagen := $MenuVBox/Menu/ContenedorVBox/Margen/Imagen
@onready var impostores_vbox := $MenuVBox/Menu/ContenedorVBox/Margen/Impostores
@onready var los_impostores_label := $MenuVBox/Menu/ContenedorVBox/Margen/Impostores/ImpvBox/LosImpostores
@onready var revelar_btn := $MenuVBox/Menu/ContenedorVBox/Revelar
@onready var siguiente_btn := $MenuVBox/Menu/ContenedorVBox/Siguiente
@onready var texto_label := $MenuVBox/Menu/ContenedorVBox/Texto
@onready var ganador_box := $MenuVBox/Menu/ContenedorVBox/Ganador
@onready var ganador_button := $MenuVBox/Menu/ContenedorVBox/Ganador/GanadorButton

# --- Configuración inicial ---
var duracion_segundos := 180  # 3 minutos

func _ready():
	timer.wait_time = 1.0
	timer.one_shot = false
	timer.start()

	duracion_segundos = 180
	_actualizar_tiempo_label()

	timer.timeout.connect(_on_timer_tick)
	revelar_btn.pressed.connect(_on_revelar)
	siguiente_btn.pressed.connect(_on_siguiente)

	impostores_vbox.visible = false
	siguiente_btn.visible = false
	ganador_box.visible = false
	texto_label.text = "Los impostores eran..."

func _on_timer_tick():
	duracion_segundos -= 1
	_actualizar_tiempo_label()

	if duracion_segundos <= 0:
		timer.stop()
		_revelar_impostores()

func _actualizar_tiempo_label():
	var minutos: int = int(float(duracion_segundos) / 60)
	var segundos := duracion_segundos % 60
	var texto := "%02d:%02d" % [minutos, segundos]
	tiempo_label.text = texto

func _on_revelar():
	timer.stop()
	_revelar_impostores()

func _revelar_impostores():
	imagen.visible = false
	impostores_vbox.visible = true
	siguiente_btn.visible = true
	ganador_box.visible = true
	texto_label.text = "¿Quién ganó?"

	var nombres: Array[String] = []

	for jugador in GameData.jugadores_actual:
		if jugador.has("es_impostor") and jugador["es_impostor"]:
			nombres.append(jugador["nombre"])

	nombres.append("")
	nombres.append("La PALABRA era:")
	nombres.append(GameData.get_palabra_actual().to_upper())

	los_impostores_label.text = "\n".join(nombres)

func _on_siguiente():
	var ganador := "jugadores" if ganador_button.button_pressed else "impostores"
	GameData.guardar_estado()
	GameData.guardar_historial_partida(ganador)
	print("✅ Partida guardada en historial como ganada por: " + ganador)
	GameData.push_scene("res://src/scenes/preparar_partida.tscn")

func _on_regresar_menu_pressed() -> void:
	GameData.guardar_estado()
	print("Estado guardado")
	ganador_box.visible = false
	texto_label.text = "Los impostores eran..."
	GameData.clear_stack()
	GameData.push_scene("res://src/scenes/menu_principal.tscn")
