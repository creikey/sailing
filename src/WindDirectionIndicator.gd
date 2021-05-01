extends MeshInstance

func _process(delta):
#	global_transform.origin = lerp(global_transform.origin, Vector3(), delta/2.0)
#	print(Wind.wind_vector)
	var right := Wind.wind_vector.cross(Vector3.UP)
	global_transform.basis = Basis(
		Wind.wind_vector,
		Wind.wind_vector.cross(right),
		right
	)
#	look_at(global_transform.origin + Vector3(-1.0, 0.0, 1.0), Vector3(0.0, 1.0, 0.0))
