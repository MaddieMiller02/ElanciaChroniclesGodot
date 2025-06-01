extends Node

@export var next_scene:PackedScene

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("ui_accept") and self.visible == true:
		get_tree().change_scene_to_packed(next_scene)
