extends Camera

export (NodePath) var look_at_path

onready var look_at: Spatial = get_node(look_at_path)

func _process(delta):
	look_at(look_at.global_transform.origin, Vector3(0.0, 1.0, 0.0))
