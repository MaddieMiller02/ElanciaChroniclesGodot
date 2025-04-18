class_name BattleMenu
extends Container

@export var VisibleStates:Array[Enums.GAME_STATE]
@export var ControlNode:Control

func _ready() -> void:
	Globals.GameStateUpdated.connect(_on_game_state_updated)

func _on_game_state_updated() -> void:
	if Globals.CurrentGameState in VisibleStates:
		ControlNode.visible = true
	else:
		ControlNode.visible = false
		
func _process(delta) -> void:
	if Globals.CurrentGameState in VisibleStates:
		ControlNode.visible = true
	else:
		ControlNode.visible = false
