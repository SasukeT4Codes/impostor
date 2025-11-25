extends Control

@onready var cant_jug := $MenuVBox/Menu/ContenedorVBox/JugadoresHBox/CantJug
@onready var cant_imp := $MenuVBox/Menu/ContenedorVBox/ImpostoresHBox/CantImp

func _ready():
	# Generar automáticamente las opciones de jugadores (3 a 14)
	for i in range(3, 15):
		cant_jug.add_item(str(i))
	# Seleccionar por defecto 3 jugadores
	cant_jug.select(0)
	# Actualizar impostores según la cantidad inicial
	_actualizar_impostores(3)
	# Conectar señal de cambio
	cant_jug.item_selected.connect(_on_cant_jug_selected)

func _on_cant_jug_selected(index:int):
	var jugadores = cant_jug.get_item_text(index).to_int()
	_actualizar_impostores(jugadores)

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
	cant_imp.select(0) # Selección por defecto
