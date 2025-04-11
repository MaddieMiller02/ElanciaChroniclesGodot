extends Ability

func perform_ability(User:BattleCharacter, Target:BattleCharacter, CurrentManager:BattleManager):
	# Calculations
	var DamageOffset = randi_range(-2, 2)
	var Damage = ((User.Strength + Power) - Target.get_defense()) + DamageOffset
	var IsWeak:bool = false
	var HitChance = (HitRate + User.get_speed()) - Target.get_speed()
	var HitRoll = randi_range(0, 100)
	
	# Resets damage to 0 if it's belwo 0
	if Damage < 0:
		Damage = 0
	
	print("Target is weak to damage type: " + str(IsWeak))
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
	User.DefaultCamera.make_current()
	
	OriginalPosition = User.position
	move_to_target(User, Target)
	await User.DestinationReachedSignal
	
	if User.Animator != null:
		User.Animator.set("parameters/conditions/Hack and Blast", true)
		await get_tree().create_timer(0.1).timeout
		User.Animator.set("parameters/conditions/Hack and Blast", false)
		await User.Animator.animation_finished
		User.ImpactCamera2.make_current()
		await User.Animator.animation_finished
		#await get_tree().create_timer(4.967).timeout
	
	CurrentManager.PlayerTurnCamera.make_current()
	move_to_start(User, Target)
	await User.DestinationReachedSignal
	
	emit_signal("AbilityFinished")
