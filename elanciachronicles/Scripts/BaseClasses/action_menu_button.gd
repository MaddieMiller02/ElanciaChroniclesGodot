class_name ActionMenuButton
extends UIButton

@export var NextAbility:Ability

func _on_game_state_updated():
	if Globals.CurrentGameState == Enums.GAME_STATE.BATTLE_MENU_NORMAL:
		self.visible = true
	else:
		self.visible = false
