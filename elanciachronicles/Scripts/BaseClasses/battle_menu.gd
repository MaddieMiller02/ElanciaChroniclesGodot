class_name BattleMenu
extends Container

@export var VisibleState:Enums.GAME_STATE
@export var ControlNode:Control

func _ready() -> void:
	Globals.GameStateUpdated.connect(_on_game_state_updated)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _on_game_state_updated() -> void:
	if Globals.CurrentGameState == VisibleState:
		ControlNode.visible = true
	else:
		ControlNode.visible = false
