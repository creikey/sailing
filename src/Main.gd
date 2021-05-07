extends Spatial

var level_scene: PackedScene = preload("res://Level.tscn")

func _ready():
	reset()

func reset():
	if $CurLevel.get_children().size() > 0:
		$CurLevel.get_children()[0].queue_free()
	var new_level = level_scene.instance()
	$CurLevel.add_child(new_level)
	$Sailboat.reset_to_transform(new_level.get_node("Spawnpoint").transform)

func _on_Sailboat_dead():
	if not $RespawnTimer.is_stopped():
		return
	for n in get_tree().get_nodes_in_group("lantern_lights"):
		n.force_off = true
	$RespawnTimer.start()

func _on_RespawnTimer_timeout():
	reset()
