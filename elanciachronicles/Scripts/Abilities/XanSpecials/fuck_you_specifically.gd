extends Ability

var Missed:bool = false

func perform_ability(User:BattleCharacter, Target:BattleCharacter, CurrentManager:BattleManager):
	OriginalPosition = User.position
	
	# Calculations
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
	
	# Moves Xan to the frontline
	User.CurrentPosition = 0
	var position_line = CurrentManager.PartyLinesControl.get_child(CurrentManager.ActiveCharacter.get_index())
	var position_marker = position_line.get_child(CurrentManager.ActiveCharacter.CurrentPosition)
	var position_line_position = position_line.position
	var position_marker_position = position_marker.position
	OriginalPosition.x = (position_line_position.x + position_marker_position.x) - 1
	CurrentManager.set_target_cursor_position(CurrentManager.ActiveCharacter)
	
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
	User.use_ap(APCost)
	
	print("User Ending AP: " + str(User.CurrentAP))
	print("Enemy Ending HP: " + str(Target.CurrentHP))
	
	# Animate the attack
	User.DefaultCamera.make_current()
	move_to_target(User, Target)
	await User.DestinationReachedSignal
	
	if User.Animator != null:
		User.ImpactCamera1.make_current()
		User.Animator.set("parameters/conditions/Melee Attack", true)
		User.Animator.set("parameters/Melee Attack Machine/conditions/Heavy Attack", true)
		if Missed:
			Target.dodge_sound()
		else:
			User.heavy_melee_sound()
			await get_tree().create_timer(User.HeavySoundDelay + 0.4).timeout
			Target.damage_animation()
		await get_tree().create_timer(0.1).timeout
		User.Animator.set("parameters/Melee Attack Machine/conditions/Heavy Attack", false)
		User.Animator.set("parameters/conditions/Melee Attack", false)
		await User.Animator.animation_finished
		
	CurrentManager.PlayerTurnCamera.make_current()
	move_to_start(User, Target)
	await User.DestinationReachedSignal
	await get_tree().create_timer(0.5).timeout
	Target.reset_damage_animations()
	
	emit_signal("AbilityFinished")
