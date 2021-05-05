extends OmniLight

export (OpenSimplexNoise) var noise

var time: float = 0.0
export var off: bool = false
onready var _base_range: float = omni_range

var _force_off: bool = false

func _ready():
	$LanternArea/CollisionShape.shape = $LanternArea/CollisionShape.shape.duplicate(true)
	$LanternArea/CollisionShape.shape.radius = _base_range/1.3
	if off:
		omni_range = 0.0

func _process(delta):
	time += delta
	if off and not _force_off:
		omni_range = lerp(omni_range, 0.0, 5.0*delta)
	else:
		omni_range = lerp(omni_range, _base_range  + noise.get_noise_1d(time)*1.0, 5.0*delta)
