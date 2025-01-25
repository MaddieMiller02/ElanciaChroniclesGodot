extends Ability

func perform_ability(User:BattleCharacter, Target:BattleCharacter):
	var Damage = (User.Strength + Power) - (Target.Defense)
	var HitChance = (HitRate + User.Speed) - Target.Speed
	var HitRoll = randi_range(0, 100)
	print("Calculated Damage: " + str(Damage))
	print("Calculated Hit Chance: " + str(HitChance))
	print("Calculated Hit Roll: " + str(HitRoll))
	print("User Starting AP: " + str(User.CurrentAP))
	print("Enemy Starting HP: " + str(Target.CurrentHP))
	if HitRoll < HitChance:
		Target.take_damage(Damage)
	User.use_ap(APCost)
	print("User Ending AP: " + str(User.CurrentAP))
	print("Enemy Ending HP: " + str(Target.CurrentHP))
