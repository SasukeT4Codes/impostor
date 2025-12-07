extends VBoxContainer

var touch_threshold_ms := 300  # Tap corto < 0.3s

func _ready():
	for boton in get_children():
		if boton is CheckButton:
			boton.mouse_filter = Control.MOUSE_FILTER_PASS
			boton.gui_input.connect(_on_checkbutton_gui_input.bind(boton))

func _on_checkbutton_gui_input(event: InputEvent, boton: CheckButton) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			boton.set_meta("touch_start", Time.get_ticks_msec())
		else:
			var start: int = int(boton.get_meta("touch_start")) if boton.has_meta("touch_start") else 0
			var duration: int = Time.get_ticks_msec() - start
			if duration < touch_threshold_ms:
				boton.button_pressed = not boton.button_pressed
				boton.emit_signal("toggled", boton.button_pressed)
			else:
				get_viewport().set_input_as_handled()
	elif event is InputEventScreenDrag:
		get_viewport().set_input_as_handled()
