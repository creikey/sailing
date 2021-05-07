extends AudioStreamPlayer

export (NodePath) var player_path

onready var player = get_node(player_path)

onready var effect: AudioEffectFilter = AudioServer.get_bus_effect(1, 0)

func _process(delta):
	effect.cutoff_hz = 4000.0*(1.0 - player.get_health())
	var target_db = -30.0 * player.get_health()
	if player.get_health() > 0.95:
		target_db = -72.0
	AudioServer.set_bus_volume_db(1, target_db)
