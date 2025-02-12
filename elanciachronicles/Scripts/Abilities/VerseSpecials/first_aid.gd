extends Ability

func perform_ability(User:BattleCharacter, Target:BattleCharacter, CurrentManager:BattleManager):
	# Calculations
	var HealAmount = User.Magic + Power
	
	print("Calculated Heal Amount: " + str(HealAmount))
	print("Target Starting HP: " + str(Target.CurrentHP))
	
	# Perform calculated outcome and dispay text boxes
	var TextBox = TextBoxScene.instantiate()
	self.add_child(TextBox)
	Target.heal(HealAmount)
	TextBox.display_heal_message(self, User, Target, HealAmount)
	User.use_ap(APCost)
	
	print("Target Ending HP: " + str(Target.CurrentHP))
