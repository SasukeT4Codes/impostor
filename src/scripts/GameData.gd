extends Node

var jugadores: Array = []

func reset_jugadores():
	jugadores.clear()

func agregar_jugador(player_id:int, nombre:String, imagen:Texture):
	var nuevo = {
		"id": player_id,
		"nombre": nombre,
		"imagen": imagen,
		"partidas_ganadas": 0
	}
	jugadores.append(nuevo)

func registrar_victoria(player_id:int):
	for j in jugadores:
		if j["id"] == player_id:
			j["partidas_ganadas"] += 1
			break

func obtener_jugador_por_id(player_id:int) -> Dictionary:
	for j in jugadores:
		if j["id"] == player_id:
			return j
	return {}
