class_name MenuCursor
extends TextureRect

@export var menu_parent:Container
@export var cursor_offset:Vector2

var cursor_index:int = 0
var previous_index:int = 0
var scroller:ScrollContainer
var active:bool = false
var previous_menus:Array[Container]
var previous_game_states:Enums.GAME_STATE

func _ready():
	Globals.GameStateUpdated.connect(_on_game_state_updated)

func _process(delta):
	if active:
		var input := Vector2.ZERO
		previous_index = cursor_index
		
		# Controls cursor movement
		if Input.is_action_just_pressed("ui_up"):
			input.y -= 1
		if Input.is_action_just_pressed("ui_down"):
			input.y += 1
		if Input.is_action_just_pressed("ui_left"):
			input.x -= 1
		if Input.is_action_just_pressed("ui_right"):
			input.x += 1
		
		if menu_parent is VBoxContainer:
			set_cursor_from_index(cursor_index + input.y)
		elif menu_parent is HBoxContainer:
			set_cursor_from_index(cursor_index + input.x)
		elif menu_parent is GridContainer:
			set_cursor_from_index(cursor_index + input.x + input.y * menu_parent.columns)

		# Triggers object selection on current object
		if Input.is_action_just_pressed("ui_select"):
			var current_menu_item := get_menu_item_at_index(cursor_index)
			if current_menu_item != null:
				if current_menu_item.has_method("cursor_select"):
					current_menu_item.cursor_select()
					
		# Backtracks to the previous menu if player presses cancel button
		if Input.is_action_just_pressed("ui_cancel"):
			backtrack_menu()
					
		if get_menu_item_at_index(previous_index) != null:
			get_menu_item_at_index(previous_index).button_unfocused()
		get_menu_item_at_index(cursor_index).button_focused()
	else:
		get_menu_item_at_index(cursor_index).button_unfocused()

func get_menu_item_at_index(index:int) -> UIButton:
		if menu_parent == null:
			return null
		
		if index >= menu_parent.get_child_count() or index < 0:
			return null
			
		return menu_parent.get_child(index) as UIButton
		

func set_cursor_from_index(index:int) -> void:
	var menu_item := get_menu_item_at_index(index)
	
	if menu_item == null:
		return
	if menu_parent.get_parent() is ScrollContainer:
		scroller = menu_parent.get_parent() as ScrollContainer
	
		
	var position = menu_item.global_position
	var size = menu_item.size
 
	cursor_index = index
	
	#TODO FIX THIS LATER
	#if scroller != null && menu_parent.get_parent() is ScrollContainer:
		#scroller.ensure_control_visible(menu_item)
		
	global_position = Vector2(position.x, position.y + size.y / 2.0) - (size / 2.0) - cursor_offset
	
func change_menu(new_menu:Container):
	get_menu_item_at_index(cursor_index).button_unfocused()
	cursor_index = 0
	menu_parent.hide()
	previous_menus.append(menu_parent)
	menu_parent = new_menu
	menu_parent.show()
	active = true

func backtrack_menu():
	# Backtracks to the previous open menu that turn
	if previous_menus.size() > 0:
		get_menu_item_at_index(cursor_index).button_unfocused()
		cursor_index = 0
		if menu_parent.get_child(0) is not CharacterUI:
			menu_parent.hide()
		menu_parent = previous_menus.pop_front()
		menu_parent.show()
		active = true
		Globals.UpdateGameState(Enums.GAME_STATE.BATTLE_MENU_NORMAL)

func clear_previous_menus():
	previous_menus.clear()
	
func _on_game_state_updated():
	if Globals.CurrentGameState == Enums.GAME_STATE.BATTLE_MENU_NORMAL or Globals.CurrentGameState == Enums.GAME_STATE.BATTLE_SELECTING_TARGET_ENEMY:
		self.visible = true
		active = true
	else:
		self.visible = false
		active = false
