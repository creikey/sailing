extends RigidBody

const fluid_density: float = 5.0
const rotation_speed: float = 0.5

onready var rudder: Spatial = $RudderPosition

func _ready():
	$SailBoatMesh.sail_angle = deg2rad(90.0)

func _physics_process(delta):
	var sail_steering: float = Input.get_action_strength("g_sail_right") - Input.get_action_strength("g_sail_left")
	$SailBoatMesh.sail_angle += sail_steering*delta*deg2rad(45.0)


func _integrate_forces(state: PhysicsDirectBodyState):
	var water_distance: float = global_transform.origin.y
	
	var water_force: float = -fluid_density * state.total_gravity.length() * water_distance
	state.add_force(Vector3(0.0, water_force, 0.0), Vector3.ZERO)

	var wind_force := 1.0 - Vector3(-1.0, 0.0, 0.0).rotated(Vector3(0.0, 1.0, 0.0), $SailBoatMesh.get_global_sail_angle()).normalized().dot(Wind.wind_vector)
	state.add_force(state.transform.basis.x*wind_force*Wind.wind_speed, Vector3.ZERO)
	#print(wind_force) 

	var horizontal_steering: float = Input.get_action_strength("g_right") - Input.get_action_strength("g_left")
	#state.transform.basis = state.transform.basis.rotated(Vector3.UP, -horizontal_steering * state.linear_velocity.length() * deg2rad(rotation_speed))
	state.add_force(rudder.global_transform.basis.z*horizontal_steering * state.linear_velocity.length(), rudder.translation)
