extends Enemy

@export var Reposition:Ability
@export var RangedAttack:Ability

func perform_turn(party:Array[PartyMember], CurrentManager:BattleManager):
	# Attack the closest enemy with a ranged attack
	var Target:PartyMember = party[0]
	for i in range(party.size()):
		var character = party[i]
		if character.CurrentPosition < Target.CurrentPosition:
			Target = character
			
	# Back up to perform ranged attack if too close
	if (CurrentPosition + Target.CurrentPosition) <= 2 and not HasRepositioned:
		print("I should be repositioning!")
		CurrentManager.MenuCursor.cursor_index = 1
		Reposition.perform_ability(self, Target, CurrentManager)
		CurrentManager.set_active_character(self)
		return
	
	RangedAttack.perform_ability(self, Target, CurrentManager)
	super.perform_turn(party, CurrentManager)
