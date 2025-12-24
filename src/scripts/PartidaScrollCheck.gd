extends VBoxContainer

func _ready():
	# Recorre todos los hijos directos
	for child in get_children():
		if child is CheckButton:
			# Ajuste de mouse_filter para permitir scroll
			child.mouse_filter = Control.MOUSE_FILTER_PASS
			# Conectar su _gui_input a una función centralizada
			child.gui_input.connect(_on_checkbutton_input.bind(child))

# Diccionario para llevar control de dragging por botón
var dragging := {}

func _on_checkbutton_input(event: InputEvent, btn: CheckButton) -> void:
	# Detectar drag en móvil
	if event is InputEventScreenDrag:
		dragging[btn] = true
		return

	# Detectar drag en PC
	if event is InputEventMouseMotion and Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		dragging[btn] = true
		return

	# Detectar release en móvil
	if event is InputEventScreenTouch and event.is_released():
		if dragging.get(btn, false):
			dragging[btn] = false
			btn.accept_event() # evita que cambie el estado
		return

	# Detectar release en PC
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
		if dragging.get(btn, false):
			dragging[btn] = false
			btn.accept_event()
		return
