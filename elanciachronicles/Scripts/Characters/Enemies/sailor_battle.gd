extends Enemy

@export var Reposition:Ability
@export var RangedAttack:Ability
@export var Defend:Ability

func perform_turn(party:Array[PartyMember], CurrentManager:BattleManager):
	if not IsDead:
		# Defend if sailor doesn't have enough AP to attack
		if CurrentAP >= RangedAttack.APCost:
			# Attack the closest enemy with a ranged attack
			var Target:PartyMember = party[0]
			for i in range(party.size()):
				var character = party[i]
				if character.CurrentPosition < Target.CurrentPosition and not Target.IsDead:
					Target = character
					
			# Back up to perform ranged attack if too close
			if (CurrentPosition + Target.CurrentPosition) <= 1 and not HasRepositioned:
				CurrentManager.MenuCursor.cursor_index = 1
				Reposition.perform_ability(self, Target, CurrentManager)
				CurrentManager.set_active_character(self)
				return
			
			# Move closer if the target is on the backline
			elif Target.CurrentPosition == 2 and CurrentPosition != 0 and not HasRepositioned:
				CurrentManager.MenuCursor.cursor_index = 0
				CurrentPosition -= 2
				Reposition.perform_ability(self, Target, CurrentManager)
				CurrentManager.set_active_character(self)
				return
			
			# Defend if the enemy is still too close to attack
			if (CurrentPosition + Target.CurrentPosition) < 1:
				Defend.perform_ability(self, Target, CurrentManager)
				
			# Perform a ranged attack if in range
			else:
				RangedAttack.perform_ability(self, Target, CurrentManager)
			super.perform_turn(party, CurrentManager)
		else:
			Defend.perform_ability(self, self, CurrentManager)
	else:
		super.perform_turn(party, CurrentManager)
