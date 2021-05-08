extends Spatial

func switch_light():
	for l in get_children():
		if l.has_method("switch_light"):
			l.switch_light()
