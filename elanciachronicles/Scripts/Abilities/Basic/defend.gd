extends Ability

func perform_ability(User:BattleCharacter, Target:BattleCharacter, CurrentManager:BattleManager):
	User.TempDefense = User.Defense / 2
	User.TempResistance = User.Resistance / 2
	
	# AP restoration
	var StartingAP:int = User.CurrentAP
	print("Starting AP: " + str(StartingAP))
	var RegainedAP:int = User.MaxAP / 3
	print("Calculated AP Regain: " + str(RegainedAP))
	User.regain_ap(RegainedAP)
	print("Final AP: " + str(User.CurrentAP))
	
	# Send confirmation message
	var TextBox = TextBoxScene.instantiate() as BattleTextBox
	add_child(TextBox)
	TextBox.display_defend_message(User, User.CurrentAP - StartingAP)
