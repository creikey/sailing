extends Spatial

export var _wind_noise: OpenSimplexNoise

var _t: float = 0.0
var sail_angle: float = 0.0 setget set_sail_angle
var wind_influence: float = 0.5

func set_sail_angle(new_sail_angle):
#	sail_angle = clamp(new_sail_angle, -PI/2.0, PI/2.0)
	sail_angle = new_sail_angle
	if has_node("Mast"):
		$Mast.rotation.y = sail_angle

func get_sail_transform() -> Transform:
	return $Mast.global_transform

#func get_global_sail_angle() -> float:
#	return global_transform.basis.get_euler().y + sail_angle

func _process(delta):
	_t += delta
	$Mast/Sail.set("blend_shapes/Key 1", (_wind_noise.get_noise_1d(_t*5.0))*0.1 + clamp(wind_influence, 0.0, 1.0))
#	print($Mast/Sail.get("blend_shapes/Key 1"))
	#rotation.x = sin(_t*1.0 + cos(_t*0.5))*0.1
	#rotation.y = cos(_t*0.9 + sin(_t*0.5 + cos(_t*0.5)))*0.07
