extends Control

# --- Referencia a los archivos de categorías ---
var categorias_archivos := {
	"Option1": "res://src/data/categorias/Comida_tipica.json",
	"Option2": "res://src/data/categorias/Profesiones_oficios.json",
	"Option3": "res://src/data/categorias/Animales.json",
	"Option4": "res://src/data/categorias/Musica.json",
	"Option5": "res://src/data/categorias/Lugares_ciudades.json",
	"Option6": "res://src/data/categorias/Tecnologia.json",
	"Option7": "res://src/data/categorias/Peliculas.json",
	"Option8": "res://src/data/categorias/Celebridades.json",
	"Option9": "res://src/data/categorias/Herramientas_cosas.json",
	"Option10": "res://src/data/categorias/Deportes_ejercicio.json"
}

var categorias_texto := {
	"Option1": "Comida típica",
	"Option2": "Profesiones y oficios",
	"Option3": "Animales",
	"Option4": "Música",
	"Option5": "Lugares y ciudades",
	"Option6": "Tecnología",
	"Option7": "Películas",
	"Option8": "Celebridades",
	"Option9": "Herramientas y cosas",
	"Option10": "Deportes y ejercicio"
}

# --- Referencias a nodos ---
@onready var perfil_pic := $MenuVBox/Menu/ContenedorVBox/Margen/PerfilPic
@onready var palabra_panel := $MenuVBox/Menu/ContenedorVBox/Margen/Palabra
@onready var revelar_btn := $MenuVBox/Menu/ContenedorVBox/Revelar
@onready var siguiente_btn := $MenuVBox/Menu/ContenedorVBox/Siguiente
@onready var nombre_label := $MenuVBox/Menu/ContenedorVBox/Nombre

# --- Panel de palabra ---
@onready var impostor_label := $MenuVBox/Menu/ContenedorVBox/Margen/Palabra/PalVBox/Impostor
@onready var categoria_label := $MenuVBox/Menu/ContenedorVBox/Margen/Palabra/PalVBox/Categoria
@onready var palabra_label := $MenuVBox/Menu/ContenedorVBox/Margen/Palabra/PalVBox/LaPalabra
@onready var label1 := $MenuVBox/Menu/ContenedorVBox/Margen/Palabra/PalVBox/Label1
@onready var label2 := $MenuVBox/Menu/ContenedorVBox/Margen/Palabra/PalVBox/Label2

# --- Variables de ronda ---
var categoria_seleccionada: String = ""
var fila_seleccionada: Array = []
var jugador_index: int = 0
var palabra_comun: String = ""
var palabra_index: int = -1
var pista_impostor: String = ""   # pista única para todos los impostores

func _ready():
	randomize()
	_reset_estado()
	revelar_btn.pressed.connect(_on_revelar_pressed)
	siguiente_btn.pressed.connect(_on_siguiente_pressed)

	_seleccionar_categoria_y_fila()
	_seleccionar_palabra_comun()
	_asignar_impostores()
	_mostrar_jugador(jugador_index)

# --- Selección de categoría y fila ---
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

# --- Selección de palabra común ---
func _seleccionar_palabra_comun():
	if fila_seleccionada.size() >= 4:
		palabra_index = randi() % 4
		palabra_comun = str(fila_seleccionada[palabra_index])
		GameData.set_palabra_actual(palabra_comun)
		print("Palabra común seleccionada (índice %d): %s" % [palabra_index, palabra_comun])
	else:
		push_error("La fila seleccionada no tiene 4 palabras")

# --- Asignación de impostores ---
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

	# --- Generar UNA sola pista para todos los impostores ---
	if fila_seleccionada.size() >= 4 and palabra_index >= 0:
		var opciones := []
		for j in range(4):
			if j != palabra_index:
				opciones.append(fila_seleccionada[j])
		pista_impostor = opciones[randi() % opciones.size()]
		print("Pista única para impostores: %s" % pista_impostor)

	# --- Asignar impostores y darles la misma pista ---
	for i in range(total_jugadores):
		var es_imp = indices.has(i)
		GameData.jugadores_actual[i]["es_impostor"] = es_imp
		if es_imp:
			GameData.jugadores_actual[i]["pista"] = pista_impostor
			print("Impostor %s recibe pista: %s" % [GameData.jugadores_actual[i]["nombre"], pista_impostor])

	print("Impostores asignados en índices:", indices)

	# --- Guardar estado completo en disco ---
	GameData.sincronizar_a_ultima()

# --- Mostrar jugador actual ---
func _mostrar_jugador(index:int):
	var jugador = GameData.obtener_jugador_actual(index)
	if jugador.size() == 0:
		return

	nombre_label.text = jugador["nombre"]

	# imagen puede ser String (ruta) o Texture
	if jugador.has("imagen"):
		var img = jugador["imagen"]
		if typeof(img) == TYPE_STRING:
			if img != "":
				var tex: Texture = load(img)
				perfil_pic.texture = tex
			else:
				perfil_pic.texture = null
		elif img is Texture:
			perfil_pic.texture = img
		else:
			perfil_pic.texture = null
	else:
		perfil_pic.texture = null

	var texto_visible = categorias_texto.get(categoria_seleccionada, categoria_seleccionada)
	var es_impostor = jugador.has("es_impostor") and jugador["es_impostor"]
	var pista_activa = GameData.get_pista_activa()

	impostor_label.visible = es_impostor

	if es_impostor:
		label1.text = "La categoría es:"
		label2.text = "Tu PISTA es:"
		categoria_label.text = texto_visible if pista_activa else "no sabes"
		palabra_label.text = jugador.get("pista", "NO HAY PISTA!").to_upper() if pista_activa else "NO HAY PISTA!"
	else:
		label1.text = "La categoría es:"
		label2.text = "Y la PALABRA es:"
		categoria_label.text = texto_visible
		palabra_label.text = palabra_comun.to_upper()

# --- Botones ---
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
		GameData.push_scene("res://src/scenes/partida.tscn")

func _reset_estado():
	perfil_pic.visible = true
	palabra_panel.visible = false
	revelar_btn.text = "Revelar"
	siguiente_btn.visible = false




func _on_regresar_menu_pressed() -> void:
	GameData.clear_stack()
	GameData.push_scene("res://src/scenes/menu_principal.tscn")
