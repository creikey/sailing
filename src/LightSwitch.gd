extends Area

export (NodePath) var path

onready var light = get_node(path)
var _used: bool = false 

func _on_LightSwitch_body_entered(body):
	if not _used and body.is_in_group("players"):
		light.off = !light.off
		_used = true
