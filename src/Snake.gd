extends Spatial

onready var _detector: Area = $PlayerDetectionArea
onready var _body: Area = $CenterPivot/BodyArea

onready var _base_height = translation.y
var _cur_movement := Vector3() # for keeping the direction of movement when in air

# ugly damage code. sad!
var _counter: float = 0.0
func _physics_process(delta):
	var detected_player: Spatial = null
	for b in _detector.get_overlapping_bodies():
		if b.is_in_group("players"):
			detected_player = b
			break
	if detected_player != null: # player nearby
		var to_player: Vector3 = detected_player.global_transform.origin - global_transform.origin
		look_at(detected_player.global_transform.origin, Vector3(0.0, 1.0, 0.0))
#		print(to_player.length())
		var movement_direction: Vector3 = to_player.normalized()
		movement_direction.y = 0.0
		if $AnimationTree.get("parameters/playback").get_current_node() == "attack": # just let it play
			movement_direction = _cur_movement
		elif to_player.length() < 20.0: # leap range, attack!
			$AnimationTree.set("parameters/conditions/attack", true)
			_cur_movement = movement_direction
			
#			$AnimationPlayer.play("attack")
#			$AnimationPlayer.queue("idle")
		else:
			pass
			$AnimationTree.set("parameters/conditions/attack", false)
		
		global_transform.origin += movement_direction * 8.0 * delta
	else:
		pass
#		translation.y = _base_height - 1.0
	
	if true: # damage doing stuff
		var player = null
		for b in _body.get_overlapping_bodies():
			if b.is_in_group("players"):
				player = b
				break
		if player != null:
			_counter += delta
			if _counter >= 0.5:
				_counter = 0.0
				player.damage(0.9)
		else:
			_counter = 0.51
