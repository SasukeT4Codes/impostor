extends Node

@onready var player := $AudioStreamPlayer

func _ready():
	player.stream = load("res://src/sounds/musica-fondo.ogg") # ajusta la ruta
	player.volume_db = -6 # volumen moderado
	player.loop = true
	player.play()
