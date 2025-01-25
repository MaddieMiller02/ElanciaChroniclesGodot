class_name UIButton
extends Node

signal cursor_selected

@export var DefaultBackground:Texture2D
@export var FocusedBackground:Texture2D
@export var ImageScene:TextureRect

func _ready():
	Globals.GameStateUpdated.connect(_on_game_state_updated)

func cursor_select() -> void:
	print(name + " emitting selected signal...")
	emit_signal("cursor_selected")
	
func button_focused():
	ImageScene.texture = FocusedBackground
	
func button_unfocused():
	ImageScene.texture = DefaultBackground

func _on_game_state_updated():
	pass
