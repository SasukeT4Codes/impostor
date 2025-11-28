extends Control

# --- Referencia a los archivos de categorías ---
var categorias_archivos := {
	"Option1": "res://src/data/categorias/Comida_tipica.json",
	"Option2": "res://src/data/categorias/Profesiones_oficios.json",
	"Option3": "res://src/data/categorias/Animales.json",
	"Option4": "res://src/data/categorias/Musica.json"
}

var categorias_texto := {
	"Option1": "Comida típica",
	"Option2": "Profesiones y oficios",
	"Option3": "Animales",
	"Option4": "Música"
}

@onready var perfil_pic := $MenuVBox/Menu/ContenedorVBox/Margen/PerfilPic
@onready var palabra_panel := $MenuVBox/Menu/ContenedorVBox/Margen/Palabra
@onready var revelar_btn := $MenuVBox/Menu/ContenedorVBox/Revelar
@onready var siguiente_btn := $MenuVBox/Menu/ContenedorVBox/Siguiente
@onready var nombre_label := $MenuVBox/Menu/ContenedorVBox/Nombre

var categoria_seleccionada: String = ""
var fila_seleccionada: Array = []
var jugador_index: int = 0

func _ready():
	_reset_estado()
	revelar_btn.pressed.connect(_on_revelar_pressed)
	siguiente_btn.pressed.connect(_on_siguiente_pressed)

	_mostrar_jugador(jugador_index)
	_seleccionar_categoria_y_fila()
	_asignar_impostores()

func _seleccionar_categoria_y_fila():
	var activas = GameData.obtener_categorias_activas()
	if activas.is_empty():
		push_error("No hay categorías activas en GameData")
		return
	
	categoria_seleccionada = activas[randi() % activas.size()]
	GameData.set_categoria_actual(categoria_seleccionada)

	if categorias_archivos.has(categoria_seleccionada):
		var ruta = categorias_archivos[categoria_seleccionada]
		var file = FileAccess.open(ruta, FileAccess.READ)
		if file:
			var data = JSON.parse_string(file.get_as_text())
			file.close()
			if typeof(data) == TYPE_ARRAY and data.size() > 0:
				fila_seleccionada = data[randi() % data.size()]
				var texto_visible = categorias_texto.get(categoria_seleccionada, categoria_seleccionada)
				print("Se seleccionó la categoría:", texto_visible)
				print("Fila seleccionada:", fila_seleccionada)
			else:
				push_error("El JSON de %s no contiene datos válidos" % categoria_seleccionada)
		else:
			push_error("No se pudo abrir el archivo en la ruta: %s" % ruta)
	else:
		push_error("No se encontró archivo para la clave interna: %s" % categoria_seleccionada)

func _asignar_impostores():
	var total_jugadores = GameData.jugadores_actual.size()
	if total_jugadores == 0:
		return

	var cantidad_impostores = GameData.get_cantidad_impostores()
	if cantidad_impostores > total_jugadores:
		cantidad_impostores = 1

	var indices := []
	while indices.size() < cantidad_impostores:
		var idx = randi() % total_jugadores
		if not indices.has(idx):
			indices.append(idx)

	for i in range(total_jugadores):
		GameData.jugadores_actual[i]["es_impostor"] = indices.has(i)

	print("Impostores asignados en índices:", indices)

func _mostrar_jugador(index:int):
	var jugador = GameData.obtener_jugador_actual(index)
	if jugador.size() > 0:
		nombre_label.text = jugador["nombre"]
		if jugador.has("imagen") and jugador["imagen"] != null:
			perfil_pic.texture = jugador["imagen"]

func _on_revelar_pressed():
	if perfil_pic.visible:
		perfil_pic.visible = false
		palabra_panel.visible = true
		revelar_btn.text = "Ocultar"
		siguiente_btn.visible = true
	else:
		perfil_pic.visible = true
		palabra_panel.visible = false
		revelar_btn.text = "Revelar"

func _on_siguiente_pressed():
	jugador_index += 1
	if jugador_index < GameData.jugadores_actual.size():
		_reset_estado()
		_mostrar_jugador(jugador_index)
	else:
		print("Todos los jugadores ya pasaron")
		# Aquí podrías cambiar de escena a la fase de juego

func _reset_estado():
	perfil_pic.visible = true
	palabra_panel.visible = false
	revelar_btn.text = "Revelar"
	siguiente_btn.visible = false
