extends Enemy

func perform_turn(party:Array[PartyMember], CurrentManager:BattleManager):
	# Attack the closest enemy with a ranged attack
	var Target:PartyMember = party[0]
	for i in range(party.size()):
		var character = party[i]
		if character.CurrentPosition < Target.CurrentPosition:
			Target = character
			
	# Back up to perform ranged attack if too close
	if (CurrentPosition + Target.CurrentPosition) >= 2:
		CurrentManager.MenuCursor.cursor_index = 1
		CurrentManager.set_active_character(self)
		return
	
	CurrentManager.RangedAttack.perform_ability(self, Target, CurrentManager)
	super.perform_turn(party, CurrentManager)
