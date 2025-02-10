extends Node

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Globals.CurrentGameState == Enums.GAME_STATE.BATTLE_MENU_SPECIALS:
		self.visible = true
	else:
		self.visible = false
