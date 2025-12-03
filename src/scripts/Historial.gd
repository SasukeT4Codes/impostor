extends Control

@onready var lista_vbox: VBoxContainer = $MenuVBox/Menu/ContenedorVBox/MargenExt/PanelFondo/MagenInt/Scroll/ListaVBox
@onready var volver_btn: Button = $MenuVBox/Menu/ContenedorVBox/Volver
@onready var borrar_todo_btn: Button = $MenuVBox/Menu/ContenedorVBox/BorrarTodo
@onready var del_confirmar_btn: Button = $MenuVBox/Menu/DelConfirmar

var datos_scene: PackedScene = preload("res://src/scenes/datos.tscn")

func _ready() -> void:
	GameData.cargar_historial()
	_del_confirmar_visible(false)
	_mostrar_historial()

	volver_btn.pressed.connect(_on_volver_pressed)
	borrar_todo_btn.pressed.connect(_on_borrar_todo_pressed)
	del_confirmar_btn.pressed.connect(_on_del_confirmar_pressed)

func _mostrar_historial() -> void:
	# Limpiar lista previa
	for child in lista_vbox.get_children():
		child.queue_free()

	if GameData.historial.is_empty():
		var label := Label.new()
		label.text = "No hay historial disponible"
		lista_vbox.add_child(label)
		return

	# Mostrar desde la más reciente (última en la lista)
	for i in range(GameData.historial.size() - 1, -1, -1):
		var partida: Dictionary = GameData.historial[i]
		var datos := datos_scene.instantiate()
		lista_vbox.add_child(datos)
		datos.call_deferred("cargar_partida", partida, i)


func _on_volver_pressed() -> void:
	_del_confirmar_visible(false)
	GameData.pop_scene()

func _on_borrar_todo_pressed() -> void:
	_del_confirmar_visible(true)

func _on_del_confirmar_pressed() -> void:
	GameData.historial.clear()
	var file := FileAccess.open("user://data/historial.json", FileAccess.WRITE)
	if file:
		var data: Dictionary = {"historial": []}
		file.store_string(JSON.stringify(data))
		file.close()
		print("✅ Historial borrado completamente")

	_del_confirmar_visible(false)
	_mostrar_historial()

func _del_confirmar_visible(valor: bool) -> void:
	del_confirmar_btn.visible = valor
