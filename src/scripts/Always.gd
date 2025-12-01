extends Node

func _unhandled_input(event):
	if event is InputEventKey and event.pressed and event.keycode == KEY_BACK:
		var current_scene = get_tree().current_scene
		if current_scene == null:
			return

		# Si estamos en el menú principal, salir
		if current_scene.scene_file_path.ends_with("menu_principal.tscn"):
			get_tree().quit()
		else:
			GameData.pop_scene()
