extends Control

@onready var avatar_btn := $JugadorX/TextureButton
@onready var nombre_edit := $JugadorX/LineEdit
@onready var perfil_list := $PerfilX

func _ready():
	perfil_list.visible = false
	avatar_btn.pressed.connect(_on_avatar_pressed)
	perfil_list.item_selected.connect(_on_perfil_selected)

	# Cargar íconos automáticamente desde assets
	for i in range(1, 8):
		var path := "res://src/assets/characters/char-%02d.png" % i
		var icon: Texture = load(path)
		if icon:
			perfil_list.add_item("", icon)

func _on_avatar_pressed():
	perfil_list.visible = not perfil_list.visible

func _on_perfil_selected(index: int):
	var icon: Texture = perfil_list.get_item_icon(index)
	if icon:
		avatar_btn.texture_normal = icon
	perfil_list.visible = false

func set_default_name(id: int):
	nombre_edit.text = "Jugador%d" % (id + 1)

func get_data() -> Dictionary:
	return {
		"id": get_index(),
		"nombre": nombre_edit.text,
		"imagen": avatar_btn.texture_normal
	}
