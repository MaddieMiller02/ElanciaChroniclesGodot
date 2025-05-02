extends Enemy

@export var Reposition:Ability
@export var MeleeAttack:Ability
@export var LightAttack:Ability
@export var MediumAttack:Ability
@export var HeavyAttack:Ability
@export var RangedAttack:Ability
@export var Defend:Ability

func perform_turn(party:Array[PartyMember], CurrentManager:BattleManager):
	if not IsDead:
		if CurrentAP >= RangedAttack.APCost:
			# Set a random enemy as target
			var Target:PartyMember = CurrentManager.PartyMembers[randi_range(0, (CurrentManager.PartyMembers.size() - 1))]
					
			if not HasRepositioned:
				
				print("Current distance to target: " + str(Target.CurrentPosition + CurrentPosition))
				# Back up to perform ranged attack if too close
				if Target.CurrentPosition == 0 and CurrentPosition != 2:
					print("Repositioning backward, enemy is too close")
					CurrentManager.MenuCursor.cursor_index = 1
					await Reposition.perform_ability(self, Target, CurrentManager)
					
					# Let the enemy act again
					CurrentManager.set_active_character(self)
					return
				
				# Move closer if the target is on the backline or midline, as long as this wouldn't put them out of attacking range
				elif Target.CurrentPosition >= 1 and CurrentPosition != 0:
					print("Repositioning forward, enemy is too far")
					CurrentManager.MenuCursor.cursor_index = 0
					await Reposition.perform_ability(self, Target, CurrentManager)
					
					# Let the enemy act again
					CurrentManager.set_active_character(self)
					return
					
			# Perform a ranged attack if in range and has enough AP, defend otherwise
			if RangedAttack.in_range(self, Target):
				await RangedAttack.perform_ability(self, Target, CurrentManager)
			elif MeleeAttack.in_range(self, Target):
				CurrentManager.AttackQueue.append(LightAttack)
				CurrentManager.AttackQueue.append(MediumAttack)
				CurrentManager.AttackQueue.append(HeavyAttack)
				await MeleeAttack.perform_ability(self, Target, CurrentManager)
			else:
				await Defend.perform_ability(self, self, CurrentManager)
				
			super.perform_turn(party, CurrentManager)
		
		# Defend if character doesn't have enough AP to attack
		else:
			await Defend.perform_ability(self, self, CurrentManager)
			super.perform_turn(party, CurrentManager)
			
	else:
		super.perform_turn(party, CurrentManager)
