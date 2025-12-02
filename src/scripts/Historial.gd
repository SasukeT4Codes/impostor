extends Control

@onready var info_label: RichTextLabel = $MenuVBox/Menu/ContenedorVBox/Margen/Impostores/ImpvBox/Info_Label
@onready var volver_btn: Button = $MenuVBox/Menu/ContenedorVBox/Volver

func _ready():
	# Cargar estado previo desde disco
	GameData.cargar_estado()

	# Mostrar info de la última partida
	var texto := "[b]Última partida:[/b]\n"
	for jugador in GameData.jugadores_ultima:
		texto += "- " + jugador.get("nombre", "??")
		if jugador.has("imagen") and jugador["imagen"] != "":
			texto += " (avatar: " + jugador["imagen"] + ")"
		if jugador.has("es_impostor") and jugador["es_impostor"]:
			texto += " [color=red](IMPOSTOR)[/color]"
		texto += "\n"

	texto += "\n[b]Categoría:[/b] " + GameData.get_categoria_actual()
	texto += "\n[b]Palabra:[/b] " + GameData.get_palabra_actual()
	texto += "\n[b]Impostores:[/b] " + str(GameData.get_cantidad_impostores())

	info_label.text = texto

	volver_btn.pressed.connect(_on_volver_pressed)

func _on_volver_pressed():
	GameData.pop_scene()


func _on_borrar_pressed() -> void:
	# Vaciar historial en memoria
	GameData.historial.clear()
	# Guardar archivo vacío
	var file := FileAccess.open("user://data/historial.json", FileAccess.WRITE)
	if file:
		var data = {"historial": GameData.historial}
		file.store_string(JSON.stringify(data))
		file.close()
		print("✅ Historial borrado")

	# Actualizar label
	info_label.text = "[i]Historial borrado[/i]"
