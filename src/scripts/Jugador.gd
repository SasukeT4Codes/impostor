extends Control

@onready var avatar_btn := $JugadorX/TextureButton
@onready var nombre_edit := $JugadorX/LineEditWrapper/LineEdit
@onready var perfil_list := $PerfilX
@onready var label_proxy := $JugadorX/LineEditWrapper/TBProxy

func _ready():
	self.mouse_filter = Control.MOUSE_FILTER_PASS
	$JugadorX.mouse_filter = Control.MOUSE_FILTER_PASS
	$PerfilX.mouse_filter = Control.MOUSE_FILTER_PASS
	avatar_btn.mouse_filter = Control.MOUSE_FILTER_PASS
	nombre_edit.mouse_filter = Control.MOUSE_FILTER_PASS

	perfil_list.visible = false
	avatar_btn.pressed.connect(_on_avatar_pressed)
	perfil_list.item_selected.connect(_on_perfil_selected)
	nombre_edit.text_changed.connect(_on_nombre_changed)
	nombre_edit.text_submitted.connect(_on_nombre_submitted)

	# Conectar proxy
	label_proxy.pressed.connect(_on_proxy_pressed)
	label_proxy.add_to_group("tbproxies")

	# Restaurar proxy cuando el LineEdit pierde foco
	nombre_edit.focus_exited.connect(func():
		label_proxy.visible = true
	)

	# Cargar íconos automáticamente
	for i in range(1, 10):
		var path := "res://src/assets/characters/char-%02d.png" % i
		var icon: Texture = load(path)
		if icon:
			perfil_list.add_item("", icon)

func _on_proxy_pressed():
	# Mostrar todos los proxies
	for proxy in get_tree().get_nodes_in_group("tbproxies"):
		proxy.visible = true
	# Ocultar solo el actual
	label_proxy.visible = false
	# Dar foco al LineEdit
	nombre_edit.grab_focus()

func _on_avatar_pressed():
	perfil_list.visible = not perfil_list.visible

func _on_perfil_selected(index: int):
	var icon: Texture = perfil_list.get_item_icon(index)
	if icon:
		avatar_btn.texture_normal = icon
		GameData.guardar_jugador_actual(get_index(), nombre_edit.text, icon)
	perfil_list.visible = false

func _on_nombre_changed(new_text: String):
	if new_text.strip_edges() != "":
		GameData.guardar_jugador_actual(get_index(), new_text, avatar_btn.texture_normal)

func _on_nombre_submitted(_new_text: String):
	GameData.guardar_jugador_actual(get_index(), nombre_edit.text, avatar_btn.texture_normal)

	var parent_vbox = get_parent()
	var index = parent_vbox.get_children().find(self)
	var next_index = index + 1
	if next_index < parent_vbox.get_child_count():
		var next_child = parent_vbox.get_child(next_index)
		if next_child.has_node("JugadorX/LineEditWrapper/LineEdit"):
			# Restaurar proxy actual
			label_proxy.visible = true
			# Ocultar proxy del siguiente
			var next_proxy = next_child.get_node("JugadorX/LineEditWrapper/TBProxy")
			next_proxy.visible = false
			# Dar foco al siguiente LineEdit
			next_child.get_node("JugadorX/LineEditWrapper/LineEdit").grab_focus()

func set_default_name(id: int):
	nombre_edit.placeholder_text = "Jugador%d" % (id + 1)

func get_data() -> Dictionary:
	return {
		"id": get_index(),
		"nombre": nombre_edit.text,
		"imagen": avatar_btn.texture_normal
	}
