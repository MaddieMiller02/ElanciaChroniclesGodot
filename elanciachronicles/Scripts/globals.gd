extends Node

signal GameStateUpdated

var InputEnabled:bool = true

var InBattle:bool = false

var CurrentGameState:Enums.GAME_STATE = Enums.GAME_STATE.OVERWORLD

func UpdateGameState(NewState:Enums.GAME_STATE):
	CurrentGameState = NewState
	GameStateUpdated.emit()
