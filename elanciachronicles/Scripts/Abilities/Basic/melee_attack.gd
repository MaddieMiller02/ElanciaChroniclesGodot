extends Ability

var Missed:bool = false

func perform_ability(User:BattleCharacter, Target:BattleCharacter, CurrentManager:BattleManager):
	var AttackQueue:Array[Ability] = CurrentManager.AttackQueue
	
	# Calculations
	var Damage = 0
	for i in range(CurrentManager.AttackQueue.size()):
		Damage += (User.get_strength() / CurrentManager.AttackQueue.size()) + CurrentManager.AttackQueue[i].Power
		User.use_ap(CurrentManager.AttackQueue[i].APCost)
	
	var DamageOffset = randi_range(-2, 2)
	Damage -= Target.get_defense()
	Damage += DamageOffset
	var IsWeak:bool = false
	
	# Resets damage to 0 if it's belwo 0
	if Damage < 0:
		Damage = 0
	
	var HitChance = (HitRate + User.get_speed()) - Target.get_speed()
	var HitRoll = randi_range(0, 100)
	
	print("Calculated Damage: " + str(Damage))
	print("Calculated Hit Chance: " + str(HitChance))
	print("Calculated Hit Roll: " + str(HitRoll))
	print("User Starting AP: " + str(User.CurrentAP))
	print("Enemy Starting HP: " + str(Target.CurrentHP))
	
	# Perform calculated outcome and dispay text boxes
	var TextBox = TextBoxScene.instantiate()
	self.add_child(TextBox)
	if HitRoll < HitChance:
		# Multiply the damage and trigger follow-up option if weakness hit
		if Target.weakness_check(self) == true:
			Damage *= 1.5
			IsWeak = true
		
		Target.take_damage(Damage)
		if IsWeak:
			TextBox.display_weak_damage_message(self, User, Target, Damage)
		else:
			TextBox.display_damage_message(self, User, Target, Damage)
			
	else:
		TextBox.display_missed_message(self, User)
		Missed = true
	
	print("User Ending AP: " + str(User.CurrentAP))
	print("Enemy Ending HP: " + str(Target.CurrentHP))
	
	OriginalPosition = User.position
	move_to_target(User, Target)
	await User.DestinationReachedSignal
	
	# Play each attack animation sequentially
	if User.Animator != null:
		
		# Enter the Melee Attack Machine
		print("Melee animation started")
		#if User is Enemy:
			#User.rotate_y(deg_to_rad(-90))
		User.Animator.set("parameters/conditions/Melee Attack", true)
		
		# Queue each subsequent animation without cutting off the previous one
		Target.reset_damage_animations()
		for i in range(AttackQueue.size()):
			# Set the camera angle
			if i == 0:
				User.DefaultCamera.make_current()
			elif i == 1:
				User.ImpactCamera1.make_current()
			elif i == 2:
				User.ImpactCamera2.make_current()
			
			if AttackQueue[i].AbilityName == "Light Melee Attack":
				print("Light attack animation queued")
				User.Animator.set("parameters/Melee Attack Machine/conditions/Light Attack", true)
				await get_tree().create_timer(0.3).timeout
				User.Animator.set("parameters/Melee Attack Machine/conditions/Light Attack", false)
				if Missed:
					await get_tree().create_timer(User.LightSoundDelay).timeout
					Target.dodge_sound()
				else:
					#if !Target.IsDead:
					User.light_melee_sound()
					await get_tree().create_timer(User.LightSoundDelay).timeout
					Target.damage_animation()
			elif AttackQueue[i].AbilityName == "Medium Melee Attack":
				print("Medium attack animation queued")
				User.Animator.set("parameters/Melee Attack Machine/conditions/Medium Attack", true)
				await get_tree().create_timer(0.3).timeout
				User.Animator.set("parameters/Melee Attack Machine/conditions/Medium Attack", false)
				if Missed:
					await get_tree().create_timer(User.MediumSoundDelay).timeout
					Target.dodge_sound()
				else:
					#if !Target.IsDead:
					User.medium_melee_sound()
					await get_tree().create_timer(User.MediumSoundDelay).timeout
					Target.damage_animation()
			elif AttackQueue[i].AbilityName == "Heavy Melee Attack":
				print("Heavy attack animation queued")
				User.Animator.set("parameters/Melee Attack Machine/conditions/Heavy Attack", true)
				await get_tree().create_timer(0.4).timeout
				User.Animator.set("parameters/Melee Attack Machine/conditions/Heavy Attack", false)
				if Missed:
					await get_tree().create_timer(User.HeavySoundDelay).timeout
					Target.dodge_sound()
				else:
					#if !Target.IsDead:
					User.heavy_melee_sound()
					await get_tree().create_timer(User.HeavySoundDelay).timeout
					Target.damage_animation()
				
			await User.Animator.animation_finished
		# If this is the last animation, return to the root animation tree, and reset the camera
		User.Animator.set("parameters/conditions/Melee Attack", false)
		CurrentManager.PlayerTurnCamera.make_current()
		
	Target.reset_damage_animations()
	Missed = false
	move_to_start(User, Target)
	await User.DestinationReachedSignal
	#User.rotation = Vector3.ZERO
	await get_tree().create_timer(0.5).timeout
	
	emit_signal("AbilityFinished")
