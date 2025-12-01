extends Control

# --- Referencias a nodos ---
@onready var timer := $MenuVBox/Titulo/Timer
@onready var tiempo_label := $MenuVBox/Titulo/Label
@onready var imagen := $MenuVBox/Menu/ContenedorVBox/Margen/Imagen
@onready var impostores_vbox := $MenuVBox/Menu/ContenedorVBox/Margen/Impostores
@onready var los_impostores_label := $MenuVBox/Menu/ContenedorVBox/Margen/Impostores/ImpvBox/LosImpostores
@onready var revelar_btn := $MenuVBox/Menu/ContenedorVBox/Revelar
@onready var siguiente_btn := $MenuVBox/Menu/ContenedorVBox/Siguiente

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

func _on_timer_tick():
	duracion_segundos -= 1
	_actualizar_tiempo_label()

	if duracion_segundos <= 0:
		timer.stop()
		_revelar_impostores()

func _actualizar_tiempo_label():
	var minutos: int = int(float(duracion_segundos) / 60)   # conversión explícita
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

	var nombres: Array[String] = []

	# Añadir impostores
	for jugador in GameData.jugadores_actual:
		if jugador.has("es_impostor") and jugador["es_impostor"]:
			nombres.append(jugador["nombre"])

	# Añadir la palabra de la ronda
	nombres.append("")  # salto de línea
	nombres.append("La PALABRA era:")
	nombres.append(GameData.get_palabra_actual().to_upper())

	los_impostores_label.text = "\n".join(nombres)


func _on_siguiente():
	print("Continuar con la siguiente fase")
	GameData.push_scene("res://src/scenes/preparar_partida.tscn")
