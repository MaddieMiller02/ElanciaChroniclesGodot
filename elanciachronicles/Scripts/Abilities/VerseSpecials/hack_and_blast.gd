extends Ability
func perform_ability(User:BattleCharacter, Target:BattleCharacter, CurrentManager:BattleManager):
	# Calculations
	var DamageOffset = randi_range(-2, 2)
	var Damage = ((User.Strength + Power) - (Target.Defense + User.TempDefense)) + DamageOffset
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
	User.use_ap(APCost)
	
	print("User Ending AP: " + str(User.CurrentAP))
	print("Enemy Ending HP: " + str(Target.CurrentHP))
