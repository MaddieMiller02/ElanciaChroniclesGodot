extends Ability

func perform_ability(User:BattleCharacter, Target:BattleCharacter, CurrentManager:BattleManager):
	# Calculations
	var DamageOffset = randi_range(-2, 2)
	var Damage = ((User.get_strength() + Power) - Target.get_defense()) + DamageOffset
	var IsWeak:bool = false
	var HitChance = (HitRate + User.get_speed()) - Target.get_speed()
	var HitRoll = randi_range(0, 100)
	
	# Resets damage to 0 if it's below 0
	if Damage < 0:
		Damage = 0
	
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
	User.use_ap(APCost)
	
	print("User Ending AP: " + str(User.CurrentAP))
	print("Enemy Ending HP: " + str(Target.CurrentHP))
	
	# Animate attack
	if User.Animator != null:
			User.look_at(Target.position)
			User.rotate_y(deg_to_rad(90))
			
			User.Animator.set("parameters/conditions/RangedAttack", true)
			await get_tree().create_timer(1.0).timeout
			User.Animator.set("parameters/conditions/RangedAttack", false)
			
			# Trigger damage or dodge animation for enemy character
			
			# Hold until the animation is completed
			if User.Animator != null:
				print("Waiting for animation to finish")
				await get_tree().create_timer(3).timeout
				print("Animation finished")
			
			User.rotation = Vector3.ZERO
			
			emit_signal("AbilityFinished")
