extends Control

# --- Referencia a los archivos de categorías ---
var categorias_archivos := {
	"Comida_tipica": "res://src/data/categorias/Comida_tipica.json",
	"Profesiones_oficios": "res://src/data/categorias/Profesiones_oficios.json",
	"Animales": "res://src/data/categorias/Animales.json",
	"Musica": "res://src/data/categorias/Musica.json"
}

# --- Referencias a nodos ---
@onready var perfil_pic := $MenuVBox/Menu/ContenedorVBox/Margen/PerfilPic
@onready var palabra_panel := $MenuVBox/Menu/ContenedorVBox/Margen/Palabra
@onready var revelar_btn := $MenuVBox/Menu/ContenedorVBox/Revelar
@onready var siguiente_btn := $MenuVBox/Menu/ContenedorVBox/Siguiente

var categoria_seleccionada: String = ""
var fila_seleccionada: Array = []

func _ready():
	# Estado inicial
	_reset_estado()

	# Conectar botones
	revelar_btn.pressed.connect(_on_revelar_pressed)
	siguiente_btn.pressed.connect(_on_siguiente_pressed)

	# --- Selección de categoría y fila ---
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
				print("Categoría:", categoria_seleccionada)
				print("Fila seleccionada:", fila_seleccionada)
			else:
				push_error("El JSON de %s no contiene datos válidos" % categoria_seleccionada)
	else:
		push_error("No se encontró archivo para la categoría: %s" % categoria_seleccionada)

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
	_reset_estado()

# --- Estado inicial / reset ---
func _reset_estado():
	perfil_pic.visible = true
	palabra_panel.visible = false
	revelar_btn.text = "Revelar"
	siguiente_btn.visible = false
