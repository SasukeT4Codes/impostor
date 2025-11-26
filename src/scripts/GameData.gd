extends Node

# --- Datos en memoria ---
var jugadores_actual: Array = []   # lo que está en pantalla ahora
var jugadores_ultima: Array = []   # copia de la última partida válida
var historial: Array = []          # todas las partidas jugadas

# --- Gestión de jugadores actuales ---
func reset_jugadores_actual():
	jugadores_actual.clear()

func guardar_jugador_actual(player_id:int, nombre:String, imagen:Texture):
	if nombre.strip_edges() == "":
		return
	var nuevo = {
		"id": player_id,
		"nombre": nombre,
		"imagen": imagen,
		"partidas_ganadas": 0
	}
	if player_id < jugadores_actual.size():
		jugadores_actual[player_id] = nuevo
	else:
		jugadores_actual.append(nuevo)

func obtener_jugador_actual(player_id:int) -> Dictionary:
	if player_id < jugadores_actual.size():
		return jugadores_actual[player_id]
	return {}

# --- Última partida ---
func sincronizar_a_ultima():
	jugadores_ultima = jugadores_actual.duplicate(true)

func obtener_jugador_ultima(player_id:int) -> Dictionary:
	if player_id < jugadores_ultima.size():
		return jugadores_ultima[player_id]
	return {}

# --- Historial ---
func guardar_historial():
	historial.append(jugadores_actual.duplicate(true))
	_guardar_json()

func cargar_historial():
	var user_path = "user://data/historial.json"
	var base_path = "res://src/data/historial.json"

	# Si no existe en user://, copiar desde res://
	if not FileAccess.file_exists(user_path):
		if FileAccess.file_exists(base_path):
			var base_file = FileAccess.open(base_path, FileAccess.READ)
			if base_file:
				var data = JSON.parse_string(base_file.get_as_text())
				if typeof(data) == TYPE_DICTIONARY and data.has("historial"):
					historial = data["historial"]
				base_file.close()
				_guardar_json() # guardar copia en user://

	# Si existe en user://, cargarlo
	else:
		var file = FileAccess.open(user_path, FileAccess.READ)
		if file:
			var data = JSON.parse_string(file.get_as_text())
			if typeof(data) == TYPE_DICTIONARY and data.has("historial"):
				historial = data["historial"]
			file.close()

func _guardar_json():
	var file = FileAccess.open("user://data/historial.json", FileAccess.WRITE)
	if file:
		var data = {"historial": historial}
		file.store_string(JSON.stringify(data))
		file.close()

# --- Registro de victorias ---
func registrar_victoria(player_id:int):
	for j in jugadores_actual:
		if j["id"] == player_id:
			j["partidas_ganadas"] += 1
			break
