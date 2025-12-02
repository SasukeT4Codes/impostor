extends Control

@onready var categoria_botones: Array = $MenuVBox/Menu/ContenedorVBox/PanelFondo/Magen/ScrollCategorias/ListaVBox.get_children()
@onready var pista_btn: CheckButton = $MenuVBox/Menu/ContenedorVBox/PistaHBox/Pista/PistaButton
@onready var continuar_btn: Button = $MenuVBox/Menu/ContenedorVBox/Continuar

func _ready() -> void:
	for boton in categoria_botones:
		if boton is CheckButton:
			boton.toggled.connect(_on_categoria_toggled)

	# Restaurar selección previa desde GameData
	var activas: Array = GameData.obtener_categorias_activas()
	if activas.is_empty():
		activas = []
		for boton in categoria_botones:
			if boton is CheckButton:
				activas.append(boton.name)
		GameData.guardar_categorias_activas(activas)

	for boton in categoria_botones:
		if boton is CheckButton:
			boton.button_pressed = activas.has(boton.name)

	pista_btn.button_pressed = GameData.get_pista_activa()

	if not continuar_btn.pressed.is_connected(_on_continuar_pressed):
		continuar_btn.pressed.connect(_on_continuar_pressed)

	# Aplicar bloqueo inicial si ya hay 3 activas
	_aplicar_bloqueo_categorias()

func _on_categoria_toggled(_pressed: bool) -> void:
	var activas: Array = []
	for boton in categoria_botones:
		if boton is CheckButton and boton.button_pressed:
			activas.append(boton.name)

	GameData.guardar_categorias_activas(activas)
	_aplicar_bloqueo_categorias()

func _aplicar_bloqueo_categorias():
	var activas := []
	for boton in categoria_botones:
		if boton is CheckButton and boton.button_pressed:
			activas.append(boton)

	if activas.size() == 3:
		# Bloquear las 3 activas
		for boton in categoria_botones:
			if boton.button_pressed:
				boton.disabled = true
			else:
				boton.disabled = false
	else:
		# Desbloquear todos
		for boton in categoria_botones:
			boton.disabled = false

func _on_continuar_pressed() -> void:
	var activas: Array = []
	for boton in categoria_botones:
		if boton is CheckButton and boton.button_pressed:
			activas.append(boton.name)

	GameData.guardar_categorias_activas(activas)
	GameData.set_pista_activa(pista_btn.button_pressed)

	GameData.push_scene("res://src/scenes/palabras.tscn")
