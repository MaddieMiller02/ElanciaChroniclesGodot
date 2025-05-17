extends Ability

var Missed:bool = false

func perform_ability(User:BattleCharacter, Target:BattleCharacter, CurrentManager:BattleManager):
	var SelectedTarget = Target
	var EnemiesToMove:Array[BattleCharacter]
	for i in range(CurrentManager.Enemies.size()):
		Target = CurrentManager.Enemies[i]
		if Target.CurrentPosition == 0:
			var DamageOffset = randi_range(-2, 2)
			var Damage = ((User.get_strength() + Power) - Target.get_defense()) + DamageOffset
			var IsWeak:bool = false
			var HitChance = (HitRate + User.get_speed()) - Target.get_speed()
			var HitRoll = randi_range(0, 100)
			
			# Resets damage to 0 if it's belwo 0
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
				EnemiesToMove.append(Target)
				
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
				
			print("Enemy Ending HP: " + str(Target.CurrentHP))
			
	User.use_ap(APCost)
	
	print("User Ending AP: " + str(User.CurrentAP))
	
	# Animate the attack
	User.DefaultCamera.make_current()
	Target = SelectedTarget
	OriginalPosition = User.position
	move_to_target(User, Target)
	await User.DestinationReachedSignal
	
	if User.Animator != null:
		User.Animator.set("parameters/conditions/Melee Attack", true)
		User.ImpactCamera2.make_current()
		if Missed:
			Target.dodge_sound()
		else:
			User.medium_melee_sound()
		User.Animator.set("parameters/Melee Attack Machine/conditions/Medium Attack", true)
		await get_tree().create_timer(User.MediumSoundDelay + 0.3).timeout
		for i in range(EnemiesToMove.size()):
			EnemiesToMove[i].damage_animation()
		await get_tree().create_timer(1).timeout#Reposition enemy backwaard
		for i in range(EnemiesToMove.size()):
				Target = EnemiesToMove[i]
				Target.CurrentPosition += 2
				var position_line = CurrentManager.EnemyLinesControl.get_child(Target.get_index())
				var position_marker = position_line.get_child(Target.CurrentPosition)
				var position_line_position = position_line.position
				var position_marker_position = position_marker.position
				Target.position.x = (position_line_position.x + position_marker_position.x) + 1
				CurrentManager.set_target_cursor_position(Target)
				Target.reset_damage_animations()
		User.Animator.set("parameters/Melee Attack Machine/conditions/Medium Attack", false)
		User.Animator.set("parameters/conditions/Melee Attack", false)
		await User.Animator.animation_finished
		
	CurrentManager.PlayerTurnCamera.make_current()
	move_to_start(User, Target)
	await User.DestinationReachedSignal
	await get_tree().create_timer(0.5).timeout
	
	emit_signal("AbilityFinished")
