extends UIButton

@export var next_scene:PackedScene

func cursor_select():
	get_tree().change_scene_to_packed(next_scene)
