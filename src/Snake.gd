extends Spatial

const max_range: float = 330.0

onready var _detector: Area = $PlayerDetectionArea
onready var _body: Area = $CenterPivot/BodyArea

onready var _initial_pos = global_transform.origin
onready var _base_height = translation.y
var _cur_movement := Vector3() # for keeping the direction of movement when in air
var _detected_player: Spatial = null

func _ready():
	$AnimationTree.active = true # so animation in editor doesn't pollute git log

# ugly damage code. sad!
var _counter: float = 0.0
func _physics_process(delta):
	_detected_player = null
	for b in _detector.get_overlapping_bodies():
		if b.is_in_group("players"):
			_detected_player = b
			break
	if _detected_player != null and _detected_player.global_transform.origin.distance_to(_initial_pos) < max_range: # player nearby
		translation.y = lerp(translation.y, _base_height, delta*3.0)
		var to_player: Vector3 = _detected_player.global_transform.origin - global_transform.origin
		
#		print(to_player.length())
		var movement_direction: Vector3 = to_player.normalized()
		movement_direction.y = 0.0
		if $AnimationTree.get("parameters/playback").get_current_node() == "attack": # just let it play
			_cur_movement = lerp(_cur_movement, movement_direction, delta)
			movement_direction = _cur_movement
		elif to_player.length() < 40.0: # leap range, attack!
			
			$AnimationTree.set("parameters/conditions/attack", true)
			$AnimationTree.set("parameters/conditions/not attacking", false)
			
			
#			$AnimationPlayer.play("attack")
#			$AnimationPlayer.queue("idle")
		else:
			look_at(_detected_player.global_transform.origin, Vector3(0.0, 1.0, 0.0))
			$AnimationTree.set("parameters/conditions/attack", false)
			$AnimationTree.set("parameters/conditions/not attacking", true)
		
		global_transform.origin += movement_direction * 12.0 * delta
	else:
		$AnimationTree.set("parameters/conditions/attack", false)
		$AnimationTree.set("parameters/conditions/not attacking", true)
		if translation.y <= _base_height - 4.0:
			global_transform.origin = lerp(global_transform.origin, _initial_pos, delta/2.0)
		translation.y = lerp(translation.y, _base_height - 5.0, 2.0 * delta)
	
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

func attacking(): # called from the attack animation
	if _detected_player == null:
		return
	look_at(_detected_player.global_transform.origin, Vector3(0.0, 1.0, 0.0))
	$SplashPlayer.play()
	_cur_movement = (_detected_player.global_transform.origin - global_transform.origin).normalized()
