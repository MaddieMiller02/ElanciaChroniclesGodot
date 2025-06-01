extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	Globals.UpdateGameState(Enums.GAME_STATE.TITLE_SCREEN)
