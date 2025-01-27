class_name Enemy
extends BattleCharacter

@export var DroppedItems:Dictionary
@export var MeleeAttack:Ability
@export var RangedAttack:Ability

func perform_turn(party:Array[PartyMember]):
	TurnEnded.emit()
