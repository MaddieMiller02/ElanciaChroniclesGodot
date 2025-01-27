class_name Enemy
extends BattleCharacter

@export var DroppedItems:Dictionary

func perform_turn(party:Array[PartyMember], CurrentManager:BattleManager):
	TurnEnded.emit()
