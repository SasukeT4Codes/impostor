extends VBoxContainer

@onready var fecha_btn: Button = $Partida/Fecha
@onready var borrar_btn: Button = $Partida/Borrar
@onready var detalle_box: ColorRect = $ColorRect
@onready var detalle_label: RichTextLabel = $ColorRect/Margin/RichTextLabel


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

var partida_data: Dictionary = {}
var index_en_historial: int = -1

func _ready() -> void:
	detalle_box.visible = false
	fecha_btn.pressed.connect(_on_fecha_pressed)
	borrar_btn.pressed.connect(_on_borrar_pressed)


func cargar_partida(data: Dictionary, index: int) -> void:
	partida_data = data
	index_en_historial = index
	fecha_btn.text = String(data.get("palabra", "???")) + " - " + String(data.get("fecha", "??/??/???? ??"))

	var texto: String = ""
	# Usar el diccionario para traducir la categoría
	var categoria_id: String = String(data.get("categoria", ""))
	var categoria_nombre: String = categorias_texto.get(categoria_id, categoria_id)
	texto += "[b]Categoría:[/b] " + categoria_nombre + "\n"

	texto += "[b]Palabra:[/b] " + String(data.get("palabra", "")) + "\n"
	texto += "[b]Ganador:[/b] " + String(data.get("ganador", "")) + "\n"

	var impostores: Array = data.get("impostores", [])
	texto += "[b]Impostores:[/b] " + ", ".join(impostores) + "\n\n"

	texto += "[b]Jugadores:[/b]\n"
	var jugadores: Array = data.get("jugadores", [])
	for j in jugadores:
		if j is Dictionary:
			var nombre: String = String(j.get("nombre", "??"))
			var es_imp: bool = bool(j.get("es_impostor", false))
			texto += "- " + nombre
			if es_imp:
				texto += " [color=red](IMPOSTOR)[/color]"
			texto += "\n"

	detalle_label.text = texto


func _on_fecha_pressed() -> void:
	detalle_box.visible = not detalle_box.visible

func _on_borrar_pressed() -> void:
	if index_en_historial >= 0 and index_en_historial < GameData.historial.size():
		GameData.historial.remove_at(index_en_historial)
		var file := FileAccess.open("user://data/historial.json", FileAccess.WRITE)
		if file:
			var data: Dictionary = {"historial": GameData.historial}
			file.store_string(JSON.stringify(data))
			file.close()
			print("✅ Registro eliminado del historial")
		queue_free()
