extends AudioStreamPlayer2D

# --- Configuración ---
var volumen_inicial: float = -20.0     # volumen de arranque (dB)
var volumen_objetivo: float = 0.0      # volumen normal (dB)
var duracion_fade_in: float = 2.0      # segundos
var duracion_fade_out: float = 2.0     # segundos
var volumen_silencio: float = -40.0    # destino del fade out (dB)

# Lista de pistas
var pistas: Array[AudioStream] = [
	preload("res://src/sounds/musica-fondo-01.ogg"),
	preload("res://src/sounds/musica-fondo-02.ogg"),
	preload("res://src/sounds/musica-fondo-03.ogg"),
	preload("res://src/sounds/musica-fondo-04.ogg"),
]

var rng: RandomNumberGenerator = RandomNumberGenerator.new()
var fade_timer: Timer
var next_timer: Timer

func _ready() -> void:
	rng.randomize()

	# Timer para fade out
	fade_timer = Timer.new()
	fade_timer.one_shot = true
	add_child(fade_timer)
	fade_timer.timeout.connect(_on_fade_timer_timeout)

	# Timer para reproducir la siguiente pista
	next_timer = Timer.new()
	next_timer.one_shot = true
	add_child(next_timer)
	next_timer.timeout.connect(_on_finished)

	# Arranque
	volume_db = volumen_inicial
	finished.connect(_on_finished)

	_reproducir_pista_aleatoria()

# --- API opcional ---
func set_volumen(db: float) -> void:
	volume_db = db

func pausar() -> void:
	stop()
	fade_timer.stop()
	next_timer.stop()

func reanudar() -> void:
	if stream:
		play()
		_fade_in()

func cambiar_pista(nueva_stream: AudioStream) -> void:
	if nueva_stream == null:
		return
	stream = nueva_stream
	volume_db = volumen_inicial
	play()
	_fade_in()
	_programar_fade_out()

# --- Lógica principal ---
func _reproducir_pista_aleatoria() -> void:
	if pistas.is_empty():
		push_warning("Musica: no hay pistas en 'pistas'.")
		return

	var idx: int = rng.randi_range(0, pistas.size() - 1)
	stream = pistas[idx]

	# Volumen y pitch aleatorio
	volume_db = volumen_inicial
	pitch_scale = rng.randf_range(0.95, 1.10)

	play()
	_fade_in()
	_programar_fade_out()

func _on_finished() -> void:
	_reproducir_pista_aleatoria()

# --- Fade in/out ---
func _fade_in() -> void:
	var t := create_tween()
	t.tween_property(self, "volume_db", volumen_objetivo, duracion_fade_in)

func _fade_out() -> void:
	var t := create_tween()
	t.tween_property(self, "volume_db", volumen_silencio, duracion_fade_out)

# --- Programar fade out y siguiente pista ---
func _programar_fade_out() -> void:
	fade_timer.stop()
	next_timer.stop()

	var track_length: float = 0.0
	if stream and stream.has_method("get_length"):
		var length_var = stream.call("get_length")
		if typeof(length_var) == TYPE_FLOAT or typeof(length_var) == TYPE_INT:
			track_length = float(length_var)

	if track_length > 0.0:
		var duracion_real: float = track_length / pitch_scale
		var inicio_fade: float = max(0.0, duracion_real - duracion_fade_out)
		fade_timer.start(inicio_fade)
		next_timer.start(duracion_real)
	else:
		# Si no hay duración, dejamos que la señal finished() lo maneje
		pass

func _on_fade_timer_timeout() -> void:
	_fade_out()
