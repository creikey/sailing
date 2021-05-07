extends OmniLight

const start_off: bool = true

export (OpenSimplexNoise) var noise

var time: float = 0.0
export var off: bool = false
onready var _base_range: float = omni_range

var force_off: bool = false

func _ready():
	$LanternArea/CollisionShape.shape = $LanternArea/CollisionShape.shape.duplicate(true)
	$LanternArea/CollisionShape.shape.radius = _base_range/1.3
	if off or start_off:
		omni_range = 0.0

func _process(delta):
	time += delta
	if off or force_off:
		$LanternArea/CollisionShape.disabled = true
		omni_range = lerp(omni_range, 0.0, 5.0*delta)
	else:
		$LanternArea/CollisionShape.disabled = false
		omni_range = lerp(omni_range, _base_range  + noise.get_noise_1d(time)*1.0, 5.0*delta)

func _on_LanternArea_body_entered(body):
	if body.is_in_group("players"):
		body.lights_in += 1

func _on_LanternArea_body_exited(body):
	if body.is_in_group("players"):
		body.lights_in -= 1
