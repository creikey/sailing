extends OmniLight

export (OpenSimplexNoise) var noise

var time: float = 0.0

func _process(delta):
	time += delta
	omni_range = 17.0 + noise.get_noise_1d(time)*1.0
