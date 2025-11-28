extends Control

@onready var categoria_botones := $MenuVBox/Menu/ContenedorVBox/PanelFondo/Magen/ScrollCategorias/ListaVBox.get_children()

func _ready():
	for boton in categoria_botones:
		if boton is CheckButton:
			boton.toggled.connect(_on_categoria_toggled)

func _on_categoria_toggled(_pressed: bool):
	var activas := 0
	for boton in categoria_botones:
		if boton is CheckButton and boton.button_pressed:
			activas += 1
	
	# Si hay exactamente 3 activas, bloquear esas 3
	if activas == 3:
		for boton in categoria_botones:
			if boton is CheckButton:
				boton.disabled = boton.button_pressed
	else:
		# Si hay más de 3, todos se desbloquean
		for boton in categoria_botones:
			if boton is CheckButton:
				boton.disabled = false

func _on_continuar_pressed() -> void:
	var activas := []
	for boton in categoria_botones:
		if boton is CheckButton and boton.button_pressed:
			activas.append(boton.name)
	GameData.guardar_categorias_activas(activas)
	get_tree().change_scene_to_file("res://src/scenes/palabras.tscn")
