extends LineEdit

var touch_start_time: int = 0
var touch_threshold_ms: int = 500  # medio segundo

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			# Guardar tiempo de inicio del toque
			touch_start_time = Time.get_ticks_msec()
		else:
			# Al soltar, medir duración
			var duration = Time.get_ticks_msec() - touch_start_time
			if duration < touch_threshold_ms:
				# Tap corto → enfocar para escribir
				grab_focus()
			else:
				# Toque largo → dejar pasar (scroll)
				release_focus()
				get_viewport().set_input_as_handled()  # evita abrir teclado
	elif event is InputEventScreenDrag:
		# Si es drag, no abrir teclado
		release_focus()
		get_viewport().set_input_as_handled()
