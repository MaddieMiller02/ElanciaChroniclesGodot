extends Enemy

func perform_turn(party:Array[PartyMember]):
	# Attack the closest enemy with a ranged attack
	var target:PartyMember = party[0]
	for i in range(party.size()):
		var character = party[i]
		if character.CurrentPosition < target.CurrentPosition:
			target = character
	RangedAttack.perform_ability(self, target)
	super.perform_turn(party)
