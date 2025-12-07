extends VBoxContainer

var touch_threshold_ms: int = 250
var drag_threshold_px: int = 20

func _ready():
	for boton in get_children():
		if boton is CheckButton:
			boton.mouse_filter = Control.MOUSE_FILTER_PASS
			boton.gui_input.connect(_on_checkbutton_gui_input.bind(boton))

func _on_checkbutton_gui_input(event: InputEvent, boton: CheckButton) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			boton.set_meta("touch_start", Time.get_ticks_msec())
			boton.set_meta("touch_pos", event.position)
		else:
			var start: int = int(boton.get_meta("touch_start")) if boton.has_meta("touch_start") else 0
			var duration: int = Time.get_ticks_msec() - start
			var start_pos: Vector2 = boton.get_meta("touch_pos") if boton.has_meta("touch_pos") else event.position
			var moved: float = event.position.distance_to(start_pos)

			if duration < touch_threshold_ms and moved < drag_threshold_px:
				# Tap corto y sin mover → toggle
				if not boton.disabled:
					boton.button_pressed = not boton.button_pressed
					boton.emit_signal("toggled", boton.button_pressed)
			else:
				# Scroll → no toggle
				event.ignore()
	elif event is InputEventScreenDrag:
		# Scroll → no toggle
		event.ignore()
