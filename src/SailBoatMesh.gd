extends Spatial

var _t: float = 0.0
var sail_angle: float = 0.0 setget set_sail_angle

func set_sail_angle(new_sail_angle):
	sail_angle = clamp(new_sail_angle, -PI/2.0, PI/2.0)
	if has_node("Mast"):
		$Mast.rotation.y = sail_angle

func get_global_sail_angle() -> float:
	return global_transform.basis.get_euler().y + sail_angle

func _process(delta):
	_t += delta
	rotation.x = sin(_t*1.0 + cos(_t*0.5))*0.1
	rotation.y = cos(_t*0.9 + sin(_t*0.5 + cos(_t*0.5)))*0.07
