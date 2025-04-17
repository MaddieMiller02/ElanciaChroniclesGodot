extends Ability

func perform_ability(User:BattleCharacter, Target:BattleCharacter, CurrentManager:BattleManager):
	# Calculations
	var HealAmount = User.get_magic() + Power
	
	print("Calculated Heal Amount: " + str(HealAmount))
	print("Target Starting HP: " + str(Target.CurrentHP))
	
	# Perform calculated outcome and dispay text boxes
	var TextBox = TextBoxScene.instantiate()
	self.add_child(TextBox)
	Target.heal(HealAmount)
	TextBox.display_heal_message(self, User, Target, HealAmount)
	User.use_ap(APCost)
	
	print("Target Ending HP: " + str(Target.CurrentHP))
	
	if User.Animator != null:
		User.DefaultCamera.make_current()
		User.Animator.set("parameters/conditions/Item", true)
		User.heal_sound()
		await get_tree().create_timer(2.67).timeout
		User.Animator.set("parameters/conditions/Item", false)
		await get_tree().create_timer(0.1).timeout
		
	CurrentManager.PlayerTurnCamera.make_current()
	
	emit_signal("AbilityFinished")
