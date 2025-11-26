extends Control

@onready var jugar_btn := $MenuVBox/Botones/BotonesVBox/Jugar
@onready var salir_btn := $MenuVBox/Botones/BotonesVBox/Salir

func _ready():
	jugar_btn.pressed.connect(_on_jugar_pressed)
	salir_btn.pressed.connect(_on_salir_pressed)

func _on_jugar_pressed():
	get_tree().change_scene_to_file("res://src/scenes/preparar_partida.tscn")

func _on_salir_pressed():
	get_tree().quit()
