extends UIButton

@export var element_to_show:Control

func cursor_select():
	if element_to_show.visible:
		element_to_show.hide()
	else:
		element_to_show.show()
