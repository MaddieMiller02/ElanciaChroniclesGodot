class_name UIButton
extends Node

signal cursor_focused
signal cursor_unfocused
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
	if ImageScene != null:
		ImageScene.texture = FocusedBackground
	emit_signal("cursor_focused")
	
func button_unfocused():
	if ImageScene != null:
		ImageScene.texture = DefaultBackground
	emit_signal("cursor_unfocused")

func _on_game_state_updated():
	pass
