extends Ability

func perform_ability(User:BattleCharacter, Target:BattleCharacter, CurrentManager:BattleManager):
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
	
	print("User Ending AP: " + str(User.CurrentAP))
	print("Enemy Ending HP: " + str(Target.CurrentHP))
	
	emit_signal("AbilityFinished")
