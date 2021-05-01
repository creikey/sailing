extends Spatial
export (NodePath) var look_at_path

onready var look_at: Spatial = get_node(look_at_path)
onready var target: Vector3 = rotation

func _input(event):
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and event is InputEventMouseMotion:
		target.x -= event.relative.y*0.01
		target.y -= event.relative.x*0.01
		target.x = clamp(target.x, -0.4*PI, -0.05)
	elif event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event is InputEventKey and event.scancode == KEY_ESCAPE and event.is_pressed():
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _process(delta):
	rotation = Quat(rotation).slerp(Quat(target), 5.0*delta).get_euler()
	global_transform.origin = look_at.global_transform.origin
	$Camera.look_at(look_at.global_transform.origin, Vector3(0.0, 1.0, 0.0))
