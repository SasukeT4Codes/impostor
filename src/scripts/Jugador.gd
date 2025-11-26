extends Control

@onready var avatar_btn := $JugadorX/TextureButton
@onready var nombre_edit := $JugadorX/LineEdit
@onready var perfil_list := $PerfilX

func _ready():
	perfil_list.visible = false
	avatar_btn.pressed.connect(_on_avatar_pressed)
	perfil_list.item_selected.connect(_on_perfil_selected)

func _on_avatar_pressed():
	perfil_list.visible = not perfil_list.visible

func _on_perfil_selected(index:int):
	# Aquí luego asignas la textura real del perfil
	avatar_btn.text = "P%d" % (index + 1)
	perfil_list.visible = false

func set_default_name(id:int):
	nombre_edit.text = "Jugador%d" % (id + 1)

func get_data() -> Dictionary:
	return {
		"id": get_index(),
		"nombre": nombre_edit.text,
		"perfil": avatar_btn.text
	}
