class_name BattleTextBox
extends Control

@export var text_label:Label

func display_damage_message(AbilityUsed:Ability, User:BattleCharacter, Target:BattleCharacter, Damage:int):
	text_label.text = User.BattlerName + " used " + AbilityUsed.AbilityName + ". " + Target.BattlerName + " took " + str(Damage) + " damage."
	self.show()
	
	Globals.UpdateGameState(Enums.GAME_STATE.BATTLE_ANIMATING)
	await get_tree().create_timer(3.0).timeout
	
	self.hide()
	
	queue_free()

func display_missed_message(AbilityUsed:Ability, User:BattleCharacter):
	text_label.text = User.BattlerName + "'s " + AbilityUsed.AbilityName + " missed!"
	
	self.show()
	
	Globals.UpdateGameState(Enums.GAME_STATE.BATTLE_ANIMATING)
	await get_tree().create_timer(3.0).timeout
	
	self.hide()
	
	queue_free()
	
func display_reposition_failed_message(User:BattleCharacter, Direction:String):
	text_label.text = User.BattlerName + " can't move any farther " + Direction + "."
	
	self.show()
	
	await get_tree().create_timer(3.0).timeout
	
	self.hide()
	
	queue_free()
	
func display_one_off_text(text:String):
	text_label.text = text
	
	self.show()
	
	await get_tree().create_timer(3.0).timeout
	
	self.hide()
	
	queue_free()
