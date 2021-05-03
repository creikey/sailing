extends MeshInstance

func _process(delta):
#	global_transform.origin = lerp(global_transform.origin, Vector3(), delta/2.0)
#	print(Wind.wind_vector)
	var wind_direction: Vector3 = Wind.wind_vector.normalized()
	var right := wind_direction.cross(Vector3.UP)
	global_transform.basis = Basis(
		wind_direction,
		wind_direction.cross(right),
		right
	)
#	look_at(global_transform.origin + Vector3(-1.0, 0.0, 1.0), Vector3(0.0, 1.0, 0.0))
