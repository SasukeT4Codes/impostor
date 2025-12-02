extends Control

@onready var cant_jug := $MenuVBox/Menu/ContenedorVBox/JugadoresHBox/CantJug
@onready var cant_imp := $MenuVBox/Menu/ContenedorVBox/ImpostoresHBox/CantImp
@onready var lista_vbox := $MenuVBox/Menu/ContenedorVBox/PanelFondo/Magen/ScrollJugadores/ListaVBox
@onready var alerta := $MenuVBox/Menu/ContenedorVBox/Alerta

var jugador_scene := preload("res://src/scenes/jugador.tscn")

func _ready():
	# Generar automáticamente las opciones de jugadores (3 a 14)
	for i in range(3, 15):
		cant_jug.add_item(str(i))

	# Restaurar cantidad previa si existe
	var cantidad_inicial := 3
	if GameData.jugadores_cantidad >= 3 and GameData.jugadores_cantidad <= 14:
		cantidad_inicial = GameData.jugadores_cantidad

	# Seleccionar en el ComboBox la cantidad previa
	var combo_index := cantidad_inicial - 3
	cant_jug.select(combo_index)

	_actualizar_impostores(cantidad_inicial)
	cant_jug.item_selected.connect(_on_cant_jug_selected)

	# Generar lista inicial de jugadores
	_generar_jugadores(cantidad_inicial)

	alerta.visible = false

func _on_cant_jug_selected(index:int):
	var jugadores = cant_jug.get_item_text(index).to_int()
	_actualizar_impostores(jugadores)
	_generar_jugadores(jugadores)

func _actualizar_impostores(jugadores:int):
	cant_imp.clear()
	var max_impostores := 1
	if jugadores >= 6 and jugadores <= 8:
		max_impostores = 2
	elif jugadores >= 9 and jugadores <= 11:
		max_impostores = 3
	elif jugadores >= 12 and jugadores <= 14:
		max_impostores = 4
	
	for i in range(1, max_impostores + 1):
		cant_imp.add_item(str(i))
	cant_imp.select(0)

func _generar_jugadores(cantidad:int):
	# 1) Guardar lo que ya hay en pantalla en GameData antes de borrar
	for child in lista_vbox.get_children():
		if child.has_method("get_data"):
			var data = child.get_data()
			if data["nombre"].strip_edges() != "":
				GameData.guardar_jugador_actual(data["id"], data["nombre"], data["imagen"])
		child.queue_free()

	# 2) TRUNCAR la lista en memoria si se reduce la cantidad
	if GameData.jugadores_actual.size() > cantidad:
		# Mantener solo los primeros "cantidad"
		var nuevos := []
		for i in range(cantidad):
			nuevos.append(GameData.jugadores_actual[i])
		GameData.jugadores_actual = nuevos
	else:
		# Si aumenta, no creamos entradas vacías en memoria; se llenan al editar
		pass

	# Actualizar cantidad y persistir
	GameData.jugadores_cantidad = cantidad
	GameData.guardar_estado()

	# 3) Crear la nueva lista visual
	for i in range(cantidad):
		var jugador = jugador_scene.instantiate()
		lista_vbox.add_child(jugador)
		jugador.set_default_name(i)

		# 4) Restaurar datos de memoria (actual) para índices válidos
		var anterior = GameData.obtener_jugador_actual(i)
		if anterior.size() > 0:
			if anterior.has("nombre") and anterior["nombre"].strip_edges() != "":
				jugador.nombre_edit.text = anterior["nombre"]
			if anterior.has("imagen") and anterior["imagen"] != "":
				var tex: Texture = load(anterior["imagen"])
				if tex:
					jugador.avatar_btn.texture_normal = tex

func _on_continuar_pressed() -> void:
	var todos_con_nombre := true
	for child in lista_vbox.get_children():
		if child.has_method("get_data"):
			var data = child.get_data()
			if data["nombre"].strip_edges() == "":
				todos_con_nombre = false
				break
	
	if todos_con_nombre:
		alerta.visible = false

		# Actualizar impostores seleccionado
		var cantidad_impostores : int = cant_imp.get_item_text(cant_imp.get_selected_id()).to_int()
		GameData.set_cantidad_impostores(cantidad_impostores)

		# Sincronizar última con la lista ya truncada y persistir
		GameData.sincronizar_a_ultima()
		GameData.guardar_historial()

		GameData.push_scene("res://src/scenes/preparar_partida.tscn")
	else:
		alerta.visible = true
