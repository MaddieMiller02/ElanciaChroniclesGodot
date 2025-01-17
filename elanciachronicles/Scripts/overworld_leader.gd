extends CharacterBody3D


const SPEED = 3

var last_dir = Vector3.ZERO

func _physics_process(delta):
	
	if !Globals.InBattle:
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
	print(last_dir.z)
	var face_direction = "side"
	if last_dir.z < -0.5:
		face_direction = "forward"
	elif last_dir.z > 0.5:
		face_direction = "back"
	
	#Play walk animation if moving...
	if direction != Vector3(0, 0, 0):
		#Or run animation if running
		if abs(velocity.x) > SPEED or abs(velocity.z) > SPEED:
			$AnimationPlayer.play(face_direction + "_run")
		else:
			$AnimationPlayer.play(face_direction + "_walk")
	#Play idle animation if not moving
	else:
		$AnimationPlayer.play(face_direction + "_idle")
		
	#Flip sprite if moving right/left
	if face_direction == "side" and direction.x > 0 :
		$Sprite3D.flip_h = true
	elif face_direction != "side" or direction.x < 0:
		$Sprite3D.flip_h = false
		
	print(face_direction)
