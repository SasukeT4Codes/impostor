extends LineEdit

var touch_start_time: int = 0
var touch_threshold_ms: int = 250

func _gui_input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		if event.pressed:
			touch_start_time = Time.get_ticks_msec()
		else:
			var duration: int = Time.get_ticks_msec() - touch_start_time
			if duration < touch_threshold_ms:
				# Tap corto → enfocar
				grab_focus()
			else:
				# Scroll → no abrir teclado
				release_focus()
				event.ignore()  # deja pasar al ScrollContainer
	elif event is InputEventScreenDrag:
		# Scroll → no abrir teclado
		release_focus()
		event.ignore()  # deja pasar al ScrollContainer
