extends Spatial

var t: float = 0.0

func _process(delta):
	t += delta
	rotation.x = sin(t*1.0 + cos(t*0.5))*0.1
	rotation.y = cos(t*0.9 + sin(t*0.5 + cos(t*0.5)))*0.07
