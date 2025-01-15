extends CharacterBody3D


const SPEED = 5.0


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)
	
	walk_animation(direction)
	move_and_slide()
	
func walk_animation(direction):
	#Start idle or walk animation based on directional input
	if direction == Vector3(0, 0, 0):
		$AnimationPlayer.play("side_idle")
	elif direction.x != 0:
		$AnimationPlayer.play("side_walk")
	elif direction.z > 0:
		$AnimationPlayer.play("front_walk")
	elif direction.z < 0:
		$AnimationPlayer.play("back_walk")
		
	#Flip sprite if moving right/left
	if direction.x > 0:
		$Sprite3D.flip_h = true
	elif direction.x < 0:
		$Sprite3D.flip_h = false
