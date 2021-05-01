extends Spatial
export (NodePath) var look_at_path

onready var look_at: Spatial = get_node(look_at_path)
onready var target_rotation: Vector3 = rotation
onready var target_distance: float = $Camera.translation.z

func _input(event):
	if Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED and event is InputEventMouseMotion:
		target_rotation.x -= event.relative.y*0.01
		target_rotation.y -= event.relative.x*0.01
		target_rotation.x = clamp(target_rotation.x, -0.4*PI, -0.05)
	elif event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.is_pressed():
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	elif event is InputEventKey and event.scancode == KEY_ESCAPE and event.is_pressed():
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	elif event.is_action_pressed("g_zoom_in"):
		target_distance -= 0.5
		target_distance = clamp(target_distance, 4.0, 50.0)
	elif event.is_action_pressed("g_zoom_out"):
		target_distance += 0.5
		target_distance = clamp(target_distance, 4.0, 50.0)

func _process(delta):
	rotation = Quat(rotation).slerp(Quat(target_rotation), 5.0*delta).get_euler()
	$Camera.translation.z = lerp($Camera.translation.z, target_distance, 9.0*delta)
	global_transform.origin = look_at.global_transform.origin
	$Camera.look_at(look_at.global_transform.origin, Vector3(0.0, 1.0, 0.0))
