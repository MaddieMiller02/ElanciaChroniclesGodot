extends Ability

func perform_ability(User:BattleCharacter, Target:BattleCharacter, CurrentManager:BattleManager):
	# Calculations
	var Damage = 0
	for i in range(CurrentManager.AttackQueue.size()):
		Damage += (User.Strength / CurrentManager.AttackQueue.size()) + CurrentManager.AttackQueue[i].Power
		User.use_ap(CurrentManager.AttackQueue[i].APCost)
	
	var DamageOffset = randi_range(-2, 2)
	Damage -= (Target.Defense + Target.TempDefense)
	Damage += DamageOffset
	
	var HitChance = (HitRate + User.Speed) - Target.Speed
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
		Target.take_damage(Damage)
		TextBox.display_damage_message(self, User, Target, Damage)
	else:
		TextBox.display_missed_message(self, User)
	
	print("User Ending AP: " + str(User.CurrentAP))
	print("Enemy Ending HP: " + str(Target.CurrentHP))
