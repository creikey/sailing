extends KinematicBody

const buoyancy: float = 50.0
const fluid_drag: float = 5.0
const rudder_torque: float = 10.0
const angular_drag: float = 2.0

onready var rudder: Spatial = $RudderPosition

var angular_vel: float = 0.0
var vel := Vector3()

func _ready():
	$SailBoatMesh.sail_angle = deg2rad(90.0)

func _physics_process(delta):
	# move sail based on sail steering
	var sail_steering: float = Input.get_action_strength("g_sail_right") - Input.get_action_strength("g_sail_left")
	$SailBoatMesh.sail_angle += sail_steering*delta*deg2rad(45.0)
	
	var cur_torque: float = 0.0
	var cur_force := Vector3()

	# ----------------- primarily forces -----------------
	
	# calculate buoyancy force
	var water_distance: float = global_transform.origin.y
	var water_force: float = -buoyancy * water_distance
	cur_force.y += water_force
	
	# add gravity
	cur_force.y += -5.0
	
	# add underwater friction
	if water_distance < 0.0:
		cur_force += (-vel.normalized()) * (pow(vel.length(), 2.0)) * fluid_drag

	# sailing force
	var sail_dot_product := Vector3(-1.0, 0.0, 0.0).rotated(Vector3(0.0, 1.0, 0.0), $SailBoatMesh.get_global_sail_angle()).normalized().dot(Wind.wind_vector.normalized())
	var wind_influence: float = 1.0 - abs(sail_dot_product)
	cur_force -= Wind.wind_vector * wind_influence
	
	# ----------------- primarily torque -----------------
	
	# rudder, keel torque, and drag force (when turning it takes away speed)
	var horizontal_steering: float = Input.get_action_strength("g_right") - Input.get_action_strength("g_left")
	var keel: Vector3 = global_transform.basis.x
	keel = keel.rotated(Vector3(0.0, 1.0, 0.0), horizontal_steering * PI/2.0)
	var against_keel_factor = 1.0 - abs(keel.normalized().dot(vel.normalized()))
#	printt(vel.length(), vel.project(keel).length())
#	vel = lerp(vel, vel.project(keel), 0.1)
	var prev_len = vel.length()
	vel = vel.project(keel.normalized())
	if abs(vel.normalized().dot(keel)) > 0.9:
		vel = vel.normalized() * prev_len
		print(vel)
#	print(vel.normalized().dot(keel))
#	cur_force += against_keel_factor * vel.project(keel.rotated(Vector3(0.0, 1.0, 0.0), PI)).normalized() * vel.length() * 10.0
	cur_torque -= horizontal_steering * rudder_torque
#	cur_force += keel.dot(vel.normalized()) * vel.rotated(Vector3(0.0, 1.0, 0.0), PI)
#	print(keel.dot(vel.normalized()))

	# torque drag
	cur_torque += -sign(angular_vel) * pow(angular_vel, 2.0) * fluid_drag

	# integrate torque
	angular_vel += cur_torque * delta
	# integrate force
	vel += cur_force * delta

	# integrate velocities
	rotation.y += angular_vel * delta
	vel = move_and_slide(vel, Vector3(0, 1, 0))
