extends AudioStreamPlayer2D

# Configuración inicial
var volumen_inicial: float = -20.0  # empieza bajito
var volumen_objetivo: float = 0.0   # volumen normal
var duracion_fade: float = 2.0      # segundos para subir

func _ready():
	volume_db = volumen_inicial
	play()
	_fade_in()

func set_volumen(db: float):
	volume_db = db

func pausar():
	stop()

func reanudar():
	play()

func cambiar_pista(nueva_stream: AudioStream):
	stream = nueva_stream
	play()

# --- Fade in suave ---
func _fade_in():
	var tween := create_tween()
	tween.tween_property(self, "volume_db", volumen_objetivo, duracion_fade)





#MusicaFondo.set_volumen(-6) # volumen moderado
#MusicaFondo.pausar()
#MusicaFondo.reanudar()
#MusicaFondo.cambiar_pista(load("res://src/assets/sounds/otra_cancion.ogg"))
