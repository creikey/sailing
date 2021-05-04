extends KinematicBody

const buoyancy: float = 50.0
const fluid_drag: float = 5.0
const rudder_torque: float = 10.0
const angular_drag: float = 2.0
const mast_drag: float = 0.5

onready var rudder: Spatial = $RudderPosition

var mast_angular_vel: float = 0.0
var angular_vel: float = 0.0
var vel := Vector3()

func calc_wing_influence(x: float, offset: float) -> float:
	return (1.0 - pow( ( (x + 0.2*offset) *5.0) , 10.0))

func _ready():
	$SailboatMesh.sail_angle = deg2rad(-90.0)

func _physics_process(delta):
	# move sail based on sail steering
#	var sail_steering: float = Input.get_action_strength("g_sail_right") - Input.get_action_strength("g_sail_left")
#	$SailboatMesh.sail_angle += sail_steering*delta*deg2rad(45.0)
	
	
	var cur_mast_torque: float = 0.0
	var cur_torque: float = 0.0
	var cur_force := Vector3()

	# ----------------- mast torques -----------------

	

	# ----------------- primarily forces -----------------
	
	# calculate buoyancy force
	var water_distance: float = global_transform.origin.y
	var water_force: float = -buoyancy * water_distance
	cur_force.y += water_force
	
	# add gravity
	cur_force.y += -5.0
	
	# add underwater friction
	if water_distance < 0.0:
#		cur_force += (-vel.normalized()) * (pow(vel.length(), 2.0)) * fluid_drag
		cur_force.y += (-sign(vel.y)) * (pow(vel.length(), 2.0)) * fluid_drag

	# sailing forces (wing and wind pushing force)
	var is_sail_tightened: bool = Input.is_action_pressed("g_pull_sail")
	var sail_transform: Transform = $SailboatMesh.get_sail_transform()
	var sail_dot_product: float = sail_transform.basis.x.dot(Wind.wind_vector.normalized())
	var wind_pushing_influence: float = 1.0 - abs(sail_dot_product)
	# Paste into desmos: \left\{-1\le x\le1:\left(1-\left(\left(\left|x\cdot0.7\right|-0.5\right)\cdot5.0\right)^{2}\right)\right\}
	var wing_influence: float = max(0.0, 1.0 - pow( (abs(sail_dot_product*0.7) - 0.5)*5.0 ,2.0))
#	if sail_dot_product > 0.0 or not is_sail_tightened:
	if not is_sail_tightened:
		wing_influence = 0.0
	cur_force -= Wind.wind_vector * wind_pushing_influence * 0.25
	cur_force += global_transform.basis.x * wing_influence * Wind.wind_vector.length() * 5.0

	if is_sail_tightened and abs($SailboatMesh.sail_angle) > PI/4.0:
		$SailboatMesh.sail_angle = lerp($SailboatMesh.sail_angle, PI/4.0 * sign($SailboatMesh.sail_angle), 10.0*delta)
#		mast_angular_vel *= -0.5

	# mast pushed by sailing force
	cur_mast_torque += wind_pushing_influence * -sign(sail_transform.basis.z.dot(Wind.wind_vector.normalized())) * 3.0

	# mast torque friction
	cur_mast_torque += -sign(mast_angular_vel) * pow(mast_angular_vel, 2.0) * mast_drag

#	if wind_pushing_influence > 0.3:
#	print(0.5 + wind_pushing_influence * sign($SailboatMesh.get_sail_transform().basis.z.dot(Wind.wind_vector.normalized())))
#	$SailboatMesh.wind_influence = 0.5 + wind_pushing_influence * sign($SailboatMesh.get_sail_transform().basis.z.dot(Wind.wind_vector.normalized()))
#	if sail_dot_product > 0.0:
#		wing_influence = calc_wing_influence(sail_dot_product, -1.0)
#	else:
#		wing_influence = calc_wing_influence(sail_dot_product, 1.0)
#	wing_influence = max(wing_influence, 0.0)
	
	
	# ----------------- primarily torque -----------------
	
	# rudder, keel torque, and drag force (when turning it takes away speed)
#	var horizontal_steering: float = Input.get_action_strength("g_right") - Input.get_action_strength("g_left")
#	var keel: Vector3 = global_transform.basis.x
#	keel = keel.rotated(Vector3(0.0, 1.0, 0.0), horizontal_steering * PI/2.0)
#	var against_keel_factor = 1.0 - abs(keel.normalized().dot(vel.normalized()))
	var horizontal_steering: float = Input.get_action_strength("g_right") - Input.get_action_strength("g_left")
	var keel: Vector3 = global_transform.basis.x
	keel = keel.rotated(Vector3(0.0, 1.0, 0.0), horizontal_steering * PI/2.0)
	cur_force += (vel.project(keel) - vel).normalized() * pow(vel.length(), 2.0)
#	printt(vel.length(), vel.project(keel).length())
#	vel = lerp(vel, vel.project(keel), 0.1)
#	var prev_len = vel.length()
#	vel = vel.project(keel.normalized())
#	if abs(vel.normalized().dot(keel)) > 0.9:
#		vel = vel.normalized() * prev_len
#		print(vel)
#	print(vel.normalized().dot(keel))
#	cur_force += against_keel_factor * vel.project(keel.rotated(Vector3(0.0, 1.0, 0.0), PI)).normalized() * vel.length() * 10.0
	cur_torque -= horizontal_steering * rudder_torque * min(vel.length()/15.0, 1.0)
#	cur_force += keel.dot(vel.normalized()) * vel.rotated(Vector3(0.0, 1.0, 0.0), PI)
#	print(keel.dot(vel.normalized()))

	# torque drag
	cur_torque += -sign(angular_vel) * pow(angular_vel, 2.0) * fluid_drag

	# integrate mast torque
	mast_angular_vel += cur_mast_torque * delta
	# integrate torque
	angular_vel += cur_torque * delta
	# integrate force
	vel += cur_force * delta

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
