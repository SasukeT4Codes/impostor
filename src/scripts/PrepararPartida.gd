extends Control

@onready var cant_jug := $MenuVBox/Menu/ContenedorVBox/JugadoresHBox/CantJug
@onready var cant_imp := $MenuVBox/Menu/ContenedorVBox/ImpostoresHBox/CantImp
@onready var lista_vbox := $MenuVBox/Menu/ContenedorVBox/PanelFondo/Magen/ScrollJugadores/ListaVBox

var jugador_scene := preload("res://src/scenes/Jugador.tscn") # ajusta la ruta

func _ready():
	# Generar automáticamente las opciones de jugadores (3 a 14)
	for i in range(3, 15):
		cant_jug.add_item(str(i))
	cant_jug.select(0)
	_actualizar_impostores(3)
	cant_jug.item_selected.connect(_on_cant_jug_selected)

	# Generar lista inicial de jugadores
	_generar_jugadores(3)

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
	# Limpiar lista previa
	for child in lista_vbox.get_children():
		child.queue_free()

	for i in range(cantidad):
		var jugador = jugador_scene.instantiate()
		lista_vbox.add_child(jugador)
		# Ahora que el nodo ya está en el árbol, podemos inicializar el nombre
		jugador.set_default_name(i)
