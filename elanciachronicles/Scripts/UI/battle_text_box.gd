class_name BattleTextBox
extends Control

@export var text_label:Label

func display_damage_message(AbilityUsed:Ability, User:BattleCharacter, Target:BattleCharacter, Damage:int):
	text_label.text = User.BattlerName + " used " + AbilityUsed.AbilityName + ". " + Target.BattlerName + " took " + str(Damage) + " damage."
	self.show()
	
	await get_tree().create_timer(3.0).timeout
	
	self.hide()
	
	queue_free()

func display_missed_message(AbilityUsed:Ability, User:BattleCharacter):
	text_label.text = User.BattlerName + "'s " + AbilityUsed.AbilityName + " missed!"
	
	self.show()
	
	await get_tree().create_timer(3.0).timeout
	
	self.hide()
	
	queue_free()
