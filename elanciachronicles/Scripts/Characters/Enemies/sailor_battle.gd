extends Enemy

@export var Reposition:Ability
@export var RangedAttack:Ability
@export var Defend:Ability

func perform_turn(party:Array[PartyMember], CurrentManager:BattleManager):
	if not IsDead:
		if CurrentAP >= RangedAttack.APCost:
			# Set the closest enemy as target
			var Target:PartyMember = party[0]
			for i in range(party.size()):
				var character = party[i]
				if character.CurrentPosition < Target.CurrentPosition and not Target.IsDead:
					Target = character
					
			if not HasRepositioned:
				# Back up to perform ranged attack if too close
				if not RangedAttack.in_range(self, Target):
					CurrentManager.MenuCursor.cursor_index = 1
					Reposition.perform_ability(self, Target, CurrentManager)
					
					# Let the enemy act again
					CurrentManager.set_active_character(self)
					return
				
				# Move closer if the target is on the backline
				elif Target.CurrentPosition == 2 and CurrentPosition != 0:
					CurrentManager.MenuCursor.cursor_index = 0
					CurrentPosition -= 2
					Reposition.perform_ability(self, Target, CurrentManager)
					
					# Let the enemy act again
					CurrentManager.set_active_character(self)
					return
					
			# Perform a ranged attack if in range and has enough AP, defend otherwise
			if RangedAttack.in_range(self, Target):
				RangedAttack.perform_ability(self, Target, CurrentManager)
			else:
				Defend.perform_ability(self, self, CurrentManager)
				
			super.perform_turn(party, CurrentManager)
		
		# Defend if character doesn't have enough AP to attack
		else:
			Defend.perform_ability(self, self, CurrentManager)
			super.perform_turn(party, CurrentManager)
	else:
		super.perform_turn(party, CurrentManager)
