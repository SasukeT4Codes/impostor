extends Control

@onready var jugar_btn := $MenuVBox/Botones/BotonesVBox/Jugar
@onready var salir_btn := $MenuVBox/Botones/BotonesVBox/Salir

func _ready():
	# Cargar estado previo desde disco
	GameData.cargar_estado()

	jugar_btn.pressed.connect(_on_jugar_pressed)
	salir_btn.pressed.connect(_on_salir_pressed)

func _on_jugar_pressed():
	GameData.push_scene("res://src/scenes/preparar_jugadores.tscn")

func _on_salir_pressed():
	get_tree().quit()
