extends Area

#export (NodePath) var path
export (Array, NodePath) var paths

#onready var light = get_node(path)
var _used: bool = false 

func _on_LightSwitch_body_entered(body):
	if not _used and body.is_in_group("players"):
		for p in paths:
			get_node(p).switch_light()
		_used = true
