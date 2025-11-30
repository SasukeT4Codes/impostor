extends Control

# --- Referencias a nodos ---
@onready var categoria_botones: Array = $MenuVBox/Menu/ContenedorVBox/PanelFondo/Magen/ScrollCategorias/ListaVBox.get_children()
@onready var pista_btn: CheckButton = $MenuVBox/Menu/ContenedorVBox/PistaHBox/Pista/PistaButton
@onready var continuar_btn: Button = $MenuVBox/Menu/ContenedorVBox/Continuar

func _ready() -> void:
	# Conectar señales de cada botón de categoría
	for boton in categoria_botones:
		if boton is CheckButton:
			boton.toggled.connect(_on_categoria_toggled)

	# Restaurar selección previa desde GameData
	var activas: Array = GameData.obtener_categorias_activas()

	# Si no hay nada guardado, activar todas por defecto
	if activas.is_empty():
		activas = []
		for boton in categoria_botones:
			if boton is CheckButton:
				activas.append(boton.name)
		GameData.guardar_categorias_activas(activas)

	# Marcar los botones según lo que haya en GameData
	for boton in categoria_botones:
		if boton is CheckButton:
			boton.button_pressed = activas.has(boton.name)

	# Restaurar estado del botón de pista
	pista_btn.button_pressed = GameData.get_pista_activa()

	# Conectar botón continuar
	if not continuar_btn.pressed.is_connected(_on_continuar_pressed):
		continuar_btn.pressed.connect(_on_continuar_pressed)

func _on_categoria_toggled(_pressed: bool) -> void:
	var activas: Array = []
	for boton in categoria_botones:
		if boton is CheckButton and boton.button_pressed:
			activas.append(boton.name)

	# --- Lógica de mínimo 3 activas ---
	if activas.size() < 3:
		# Si el jugador intenta dejar menos de 3, reactivar todas
		for boton in categoria_botones:
			if boton is CheckButton:
				boton.button_pressed = true
		activas = []
		for boton in categoria_botones:
			if boton is CheckButton:
				activas.append(boton.name)

	# Guardar inmediatamente en GameData
	GameData.guardar_categorias_activas(activas)

func _on_continuar_pressed() -> void:
	var activas: Array = []
	for boton in categoria_botones:
		if boton is CheckButton and boton.button_pressed:
			activas.append(boton.name)

	# Guardar categorías activas en GameData
	GameData.guardar_categorias_activas(activas)

	# Guardar si la pista está activa
	GameData.set_pista_activa(pista_btn.button_pressed)
	
	# Pasar a la escena de palabras
	get_tree().change_scene_to_file("res://src/scenes/palabras.tscn")
