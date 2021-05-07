extends KinematicBody

signal dead

const drag: float = 0.1
const rudder_torque: float = 4.0
const angular_drag: float = 5.0

onready var _rudder: Spatial = $RudderPosition

var _mast_angular_vel: float = 0.0
var _angular_vel: float = 0.0
var lights_in: int = 0 # set by lantern light areas
var _vel := Vector3()
var _health: float = 1.0

func calc_wing_influence(x: float, offset: float) -> float:
	return (1.0 - pow( ( (x + 0.2*offset) *5.0) , 10.0))

# used for stuff like increased woosh as player gets closer to death
# this is assumed to output 0.0 < health < 1.0
func get_health() -> float:
	return clamp(_health, 0.0, 1.0)

func reset_to_transform(t: Transform):
	_vel = Vector3()
	_health = 1.0
	_angular_vel = 0.0
	_mast_angular_vel = 0.0
	lights_in = 0
	global_transform = t

func _ready():
	pass
#	$SailboatMesh.sail_angle = deg2rad(-90.0)

func _physics_process(delta):
	if lights_in <= 0:
		_health -= delta/2.0
		if _health <= 0.0:
			emit_signal("dead")
	else:
		_health = 1.0
	
	var cur_mast_torque: float = 0.0
	var cur_torque: float = 0.0
	var cur_force := Vector3()

	# turning
	var horizontal_steering: float = Input.get_action_strength("g_right") - Input.get_action_strength("g_left") 
	cur_torque -= horizontal_steering * rudder_torque # "steering" torque
	cur_torque += -sign(_angular_vel) * pow(_angular_vel, 2.0) * angular_drag # steering drag
	if abs(_angular_vel) < 0.05: # steering drag gets too small to slow down the tiniest of velocities
		_angular_vel = 0.0
	
	# sailing accel
	var sailing_force: float = 1.0 # always pushes a little bit
	# stronger when the sail is facing perpendicular to the wind
	sailing_force += (1.0 - abs(Wind.wind_vector.normalized().dot(global_transform.basis.z)))*20.0
	cur_force += global_transform.basis.x * sailing_force
	
	# drag
	cur_force += (-_vel.normalized()) * (pow(_vel.length(), 2.0)) * drag
	
	# constant force to slow down non forward velocity
	cur_force -= (_vel - _vel.project(global_transform.basis.x)).normalized()*3.0

	# integrate mast torque
	_mast_angular_vel += cur_mast_torque * delta
	# integrate torque
	_angular_vel += cur_torque * delta
	# integrate force
	_vel += cur_force * delta

	# bring boat to ground
	var water_distance: float = global_transform.origin.y
	if water_distance > 0.0:
		_vel.y = -5.0
	else:
		_vel.y = 0.0

	# integrate velocities
	$SailboatMesh.sail_angle += _mast_angular_vel * delta
	rotation.y += _angular_vel * delta
	_vel = move_and_slide(_vel, Vector3(0, 1, 0))
	
	# bounce mast and clamp to -90 deg < x < 90 deg 
	if $SailboatMesh.sail_angle < -PI/2.0:
		$SailboatMesh.sail_angle = -PI/2.0
		_mast_angular_vel *= -0.8
	elif $SailboatMesh.sail_angle > PI/2.0:
		$SailboatMesh.sail_angle = PI/2.0
		_mast_angular_vel *= -0.8
