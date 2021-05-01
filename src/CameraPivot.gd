extends Spatial

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
	rotation = lerp(rotation, target, 5.0*delta)
