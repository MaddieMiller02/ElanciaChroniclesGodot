extends CharacterBody3D


const SPEED = 3

var last_dir = Vector3.ZERO

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
	
	# Check for if sprinting
	if Input.is_action_pressed("dash") and input_dir != Vector2(0,0):
		velocity.x *= 2
		velocity.z *= 2
	
	walk_animation(direction)
	move_and_slide()
	
	#Sets last direction moved in unless the player is not moving (to determine idle animation)
	if direction != Vector3.ZERO:
		last_dir = direction
	
func walk_animation(direction):
	#Sets direction for character to face
	var face_direction = "side"
	if last_dir.z > 0:
		face_direction = "front"
	elif last_dir.z < 0:
		face_direction = "back"
		
	#Start idle or walk animation based on directional input
	if direction == Vector3(0, 0, 0):
		$AnimationPlayer.play(face_direction + "_idle")
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
