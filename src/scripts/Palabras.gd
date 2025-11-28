extends Control

# --- Referencia a los archivos de categorías ---
# Claves internas (OptionX) → rutas de archivo
var categorias_archivos := {
	"Option1": "res://src/data/categorias/Comida_tipica.json",
	"Option2": "res://src/data/categorias/Profesiones_oficios.json",
	"Option3": "res://src/data/categorias/Animales.json",
	"Option4": "res://src/data/categorias/Musica.json"
}

# --- Texto visible por clave interna ---
# Claves internas (OptionX) → texto que ve el jugador
var categorias_texto := {
	"Option1": "Comida típica",
	"Option2": "Profesiones y oficios",
	"Option3": "Animales",
	"Option4": "Música"
}

# --- Referencias a nodos ---
@onready var perfil_pic := $MenuVBox/Menu/ContenedorVBox/Margen/PerfilPic
@onready var palabra_panel := $MenuVBox/Menu/ContenedorVBox/Margen/Palabra
@onready var revelar_btn := $MenuVBox/Menu/ContenedorVBox/Revelar
@onready var siguiente_btn := $MenuVBox/Menu/ContenedorVBox/Siguiente
@onready var nombre_label := $MenuVBox/Menu/ContenedorVBox/Nombre   # Label del jugador

var categoria_seleccionada: String = ""  # clave interna OptionX
var fila_seleccionada: Array = []
var jugador_index: int = 0   # índice del jugador actual

func _ready():
	# Estado inicial
	_reset_estado()

	# Conectar botones
	revelar_btn.pressed.connect(_on_revelar_pressed)
	siguiente_btn.pressed.connect(_on_siguiente_pressed)

	# --- Mostrar jugador inicial ---
	_mostrar_jugador(jugador_index)

	# --- Selección de categoría y fila ---
	var activas = GameData.obtener_categorias_activas()  # debe contener OptionX
	if activas.is_empty():
		push_error("No hay categorías activas en GameData")
		return
	
	# Elegir una categoría al azar entre las activas (clave interna OptionX)
	categoria_seleccionada = activas[randi() % activas.size()]
	GameData.set_categoria_actual(categoria_seleccionada)  # guardamos la clave interna

	# Buscar la ruta del archivo con la clave interna
	if categorias_archivos.has(categoria_seleccionada):
		var ruta = categorias_archivos[categoria_seleccionada]
		var file = FileAccess.open(ruta, FileAccess.READ)
		if file:
			var data = JSON.parse_string(file.get_as_text())
			file.close()
			if typeof(data) == TYPE_ARRAY and data.size() > 0:
				fila_seleccionada = data[randi() % data.size()]
				
				# Imprimir el TEXTO visible usando el mapa local, no buscando nodos
				var texto_visible = categorias_texto.get(categoria_seleccionada, categoria_seleccionada)
				print("Se seleccionó la categoría:", texto_visible)
				print("Fila seleccionada:", fila_seleccionada)
			else:
				push_error("El JSON de %s no contiene datos válidos" % categoria_seleccionada)
		else:
			push_error("No se pudo abrir el archivo en la ruta: %s" % ruta)
	else:
		push_error("No se encontró archivo para la clave interna: %s" % categoria_seleccionada)

# --- Mostrar jugador actual ---
func _mostrar_jugador(index:int):
	var jugador = GameData.obtener_jugador_actual(index)
	if jugador.size() > 0:
		nombre_label.text = jugador["nombre"]
		if jugador.has("imagen") and jugador["imagen"] != null:
			perfil_pic.texture = jugador["imagen"]

# --- Botón Revelar (toggle) ---
func _on_revelar_pressed():
	if perfil_pic.visible:
		# Mostrar palabra
		perfil_pic.visible = false
		palabra_panel.visible = true
		revelar_btn.text = "Ocultar"
		siguiente_btn.visible = true
	else:
		# Volver a mostrar imagen
		perfil_pic.visible = true
		palabra_panel.visible = false
		revelar_btn.text = "Revelar"
		# El botón siguiente sigue visible si ya se reveló al menos una vez

# --- Botón Siguiente ---
func _on_siguiente_pressed():
	jugador_index += 1
	if jugador_index < GameData.jugadores_actual.size():
		_reset_estado()
		_mostrar_jugador(jugador_index)
	else:
		print("Todos los jugadores ya pasaron")
		# Aquí podrías cambiar de escena a la fase de juego

# --- Estado inicial / reset ---
func _reset_estado():
	perfil_pic.visible = true
	palabra_panel.visible = false
	revelar_btn.text = "Revelar"
	siguiente_btn.visible = false
