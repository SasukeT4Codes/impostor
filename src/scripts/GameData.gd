extends Node

# --- Datos en memoria ---
var jugadores_actual: Array = []   # lo que está en pantalla ahora
var jugadores_ultima: Array = []   # copia de la última partida válida
var jugadores_cantidad: int = 0    # cantidad de jugadores de la última partida
var historial: Array = []          # todas las partidas jugadas
var cantidad_impostores: int = 1

# --- Categorías ---
var categorias_activas: Array = []
var categoria_actual: String = ""
var pista_activa: bool = true
var palabra_actual: String = ""

# --- Stack de escenas ---
var escena_stack: Array = []

func push_scene(path: String):
	if get_tree().current_scene != null:
		escena_stack.append(get_tree().current_scene.scene_file_path)
	get_tree().change_scene_to_file(path)

func pop_scene():
	if escena_stack.size() > 0:
		var last_path = escena_stack.pop_back()
		get_tree().change_scene_to_file(last_path)
	else:
		get_tree().quit()

func clear_stack():
	escena_stack.clear()

# --- Gestión de jugadores actuales ---
func reset_jugadores_actual():
	jugadores_actual.clear()

func guardar_jugador_actual(player_id:int, nombre:String, imagen:Texture):
	if nombre.strip_edges() == "":
		return
	var ruta_imagen := ""
	if imagen != null and imagen.resource_path != "":
		ruta_imagen = imagen.resource_path

	var nuevo = {
		"id": player_id,
		"nombre": nombre,
		"imagen": ruta_imagen,
		"partidas_ganadas": 0,
		"es_impostor": false
	}
	if player_id < jugadores_actual.size():
		jugadores_actual[player_id] = nuevo
	else:
		jugadores_actual.append(nuevo)

func obtener_jugador_actual(player_id:int) -> Dictionary:
	if player_id < jugadores_actual.size():
		return jugadores_actual[player_id]
	return {}

func set_cantidad_impostores(valor:int):
	cantidad_impostores = valor
	guardar_estado()

func get_cantidad_impostores() -> int:
	return cantidad_impostores

# --- Última partida ---
func sincronizar_a_ultima():
	jugadores_ultima = jugadores_actual.duplicate(true)
	jugadores_cantidad = jugadores_ultima.size()
	guardar_estado()

func obtener_jugador_ultima(player_id:int) -> Dictionary:
	if player_id < jugadores_ultima.size():
		return jugadores_ultima[player_id]
	return {}

# --- Estado completo ---
func guardar_estado():
	var dir := DirAccess.open("user://")
	if not dir.dir_exists("data"):
		dir.make_dir("data")

	var file := FileAccess.open("user://data/estado.json", FileAccess.WRITE)
	if file == null:
		print("ERROR: No se pudo abrir estado.json para escritura")
		return

	var data = {
		"jugadores_ultima": jugadores_ultima,
		"jugadores_cantidad": jugadores_cantidad,
		"categorias_activas": categorias_activas,
		"categoria_actual": categoria_actual,
		"pista_activa": pista_activa,
		"palabra_actual": palabra_actual,
		"cantidad_impostores": cantidad_impostores
	}
	file.store_string(JSON.stringify(data))
	file.close()
	print("✅ estado.json guardado correctamente")

func cargar_estado():
	var path = "user://data/estado.json"
	if FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.READ)
		if file:
			var data = JSON.parse_string(file.get_as_text())
			if typeof(data) == TYPE_DICTIONARY:
				if data.has("jugadores_ultima"):
					jugadores_ultima = data["jugadores_ultima"]
				if data.has("jugadores_cantidad"):
					jugadores_cantidad = int(data["jugadores_cantidad"])
				if data.has("categorias_activas"):
					categorias_activas = data["categorias_activas"]
				if data.has("categoria_actual"):
					categoria_actual = data["categoria_actual"]
				if data.has("pista_activa"):
					pista_activa = data["pista_activa"]
				if data.has("palabra_actual"):
					palabra_actual = data["palabra_actual"]
				if data.has("cantidad_impostores"):
					cantidad_impostores = int(data["cantidad_impostores"])
			file.close()

# --- Historial detallado ---
func guardar_historial_partida(ganador:String):
	var dir := DirAccess.open("user://")
	if not dir.dir_exists("data"):
		dir.make_dir("data")

	# Leer historial existente
	var data := {}
	var file := FileAccess.open("user://data/historial.json", FileAccess.READ)
	if file:
		data = JSON.parse_string(file.get_as_text())
		file.close()

	if not data or not data.has("historial"):
		data = {"historial": []}

	# Construir entrada de partida
	var partida = {
		"id": data["historial"].size() + 1,
		"jugadores": jugadores_actual.duplicate(true),
		"impostores": jugadores_actual.filter(func(j): return j.get("es_impostor", false)).map(func(j): return j["nombre"]),
		"categoria": get_categoria_actual(),
		"palabra": get_palabra_actual(),
		"pista": pista_activa,
		"fecha": Time.get_datetime_string_from_system(),
		"ganador": ganador
	}

	data["historial"].append(partida)
	historial = data["historial"]

	# Guardar archivo
	file = FileAccess.open("user://data/historial.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	print("✅ Partida añadida al historial")

func cargar_historial():
	var user_path = "user://data/historial.json"
	if FileAccess.file_exists(user_path):
		var file = FileAccess.open(user_path, FileAccess.READ)
		if file:
			var data = JSON.parse_string(file.get_as_text())
			if typeof(data) == TYPE_DICTIONARY and data.has("historial"):
				historial = data["historial"]
			file.close()

# --- Registro de victorias ---
func registrar_victoria(player_id:int):
	for j in jugadores_actual:
		if j["id"] == player_id:
			j["partidas_ganadas"] += 1
			break

# --- Gestión de categorías ---
func reset_categorias():
	categorias_activas.clear()
	categoria_actual = ""

func guardar_categorias_activas(lista:Array):
	categorias_activas = lista.duplicate(true)
	guardar_estado()

func obtener_categorias_activas() -> Array:
	return categorias_activas

func set_categoria_actual(nombre:String):
	categoria_actual = nombre
	guardar_estado()

func get_categoria_actual() -> String:
	return categoria_actual

func set_pista_activa(valor: bool):
	pista_activa = valor
	guardar_estado()

func get_pista_activa() -> bool:
	return pista_activa

func set_palabra_actual(palabra: String):
	palabra_actual = palabra
	guardar_estado()

func get_palabra_actual() -> String:
	return palabra_actual
