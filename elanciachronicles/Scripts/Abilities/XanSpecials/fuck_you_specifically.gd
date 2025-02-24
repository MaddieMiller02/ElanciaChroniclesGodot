extends Ability

func perform_ability(User:BattleCharacter, Target:BattleCharacter, CurrentManager:BattleManager):
	# Calculations
	var DamageOffset = randi_range(-2, 2)
	var Damage = ((User.Strength + Power) - (Target.Defense + User.TempDefense)) + DamageOffset
	var IsWeak:bool = false
	if Target.weakness_check(self) == true:
		Damage *= 1.5
		IsWeak = true
	var HitChance = (HitRate + User.Speed) - Target.Speed
	var HitRoll = randi_range(0, 100)
	
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
	CurrentManager.ActiveCharacter.position.x = (position_line_position.x + position_marker_position.x) - 1
	CurrentManager.set_target_cursor_position(CurrentManager.ActiveCharacter)
	
	# Perform calculated outcome and dispay text boxes
	var TextBox = TextBoxScene.instantiate()
	self.add_child(TextBox)
	if HitRoll < HitChance:
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
