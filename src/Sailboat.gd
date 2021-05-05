extends KinematicBody

const drag: float = 0.5
const rudder_torque: float = 4.0
const angular_drag: float = 5.0

onready var rudder: Spatial = $RudderPosition

var mast_angular_vel: float = 0.0
var angular_vel: float = 0.0
var vel := Vector3()

func calc_wing_influence(x: float, offset: float) -> float:
	return (1.0 - pow( ( (x + 0.2*offset) *5.0) , 10.0))

func _ready():
	pass
#	$SailboatMesh.sail_angle = deg2rad(-90.0)

func _physics_process(delta):
	var cur_mast_torque: float = 0.0
	var cur_torque: float = 0.0
	var cur_force := Vector3()

	# turning
	var horizontal_steering: float = Input.get_action_strength("g_right") - Input.get_action_strength("g_left") 
	cur_torque -= horizontal_steering * rudder_torque # "steering" torque
	cur_torque += -sign(angular_vel) * pow(angular_vel, 2.0) * angular_drag # steering drag
	if abs(angular_vel) < 0.05: # steering drag gets too small to slow down the tiniest of velocities
		angular_vel = 0.0
	
	# sailing accel
	var sailing_force: float = 1.0 # always pushes a little bit
	# stronger when the sail is facing perpendicular to the wind
	sailing_force += (1.0 - abs(Wind.wind_vector.normalized().dot(global_transform.basis.z)))*20.0
	cur_force += global_transform.basis.x * sailing_force
	
	# drag
	cur_force += (-vel.normalized()) * (pow(vel.length(), 2.0)) * drag
	
	# constant force to slow down non forward velocity
	cur_force -= (vel - vel.project(global_transform.basis.x)).normalized()*3.0

	# integrate mast torque
	mast_angular_vel += cur_mast_torque * delta
	# integrate torque
	angular_vel += cur_torque * delta
	# integrate force
	vel += cur_force * delta

	# bring boat to ground
	var water_distance: float = global_transform.origin.y
	if water_distance > 0.0:
		vel.y = -5.0
	else:
		vel.y = 0.0

	# integrate velocities
	$SailboatMesh.sail_angle += mast_angular_vel * delta
	rotation.y += angular_vel * delta
	vel = move_and_slide(vel, Vector3(0, 1, 0))
	
	# bounce mast and clamp to -90 deg < x < 90 deg 
	if $SailboatMesh.sail_angle < -PI/2.0:
		$SailboatMesh.sail_angle = -PI/2.0
		mast_angular_vel *= -0.8
	elif $SailboatMesh.sail_angle > PI/2.0:
		$SailboatMesh.sail_angle = PI/2.0
		mast_angular_vel *= -0.8
