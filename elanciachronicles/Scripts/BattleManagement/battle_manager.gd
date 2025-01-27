class_name BattleManager
extends Node3D

var PartyMemberUI = preload("res://Scenes/UI/PartyMemberUI.tscn")
var EnemyUI = preload("res://Scenes/UI/EnemyUI.tscn")
var TextBoxScene = preload("res://Scenes/UI/BattleTextBox.tscn")

@export var PartyControlNode:Node
var PartyMembers:Array[PartyMember]
@export var EnemyControlNode:Node
var Enemies:Array[Enemy]
var BattleCharacters:Array[BattleCharacter]
var TurnOrder:Array[BattleCharacter]

var ActiveCharacter:BattleCharacter
var ActiveAbility:Ability
var TargetCharacter:BattleCharacter

@export var PartyUIContainer:Container
@export var EnemyUIControl:Node
@export var EnemyUIContainer:Container

@export var ActionMenuContainer:Container
@export var RepositionMenuControl:Node
@export var RepositionMenuContainer:Container
@export var RangedAttackButton:ActionMenuButton
@export var RepositionButton:ActionMenuButton

@export var PartyLinesControl:Node
@export var EnemyLinesControl:Node

@export var MenuCursor:MenuCursor

@export var TargetCursor:Node3D

func _ready():
	Globals.UpdateGameState(Enums.GAME_STATE.BATTLE)
	
	# Set up arrays, UI, and positioning for party members
	for i in range(PartyControlNode.get_child_count()):
		
		# Array
		var character = PartyControlNode.get_child(i) as PartyMember
		PartyMembers.append(character)
		BattleCharacters.append(character)
		
		# UI
		var new_ui = PartyMemberUI.instantiate() as CharacterUI
		new_ui.Character = character
		new_ui.set_label_name()
		new_ui.set_hp_max()
		new_ui.set_hp_current()
		new_ui.set_ap_max()
		new_ui.set_ap_current()
		PartyUIContainer.add_child(new_ui)
		
		# Positioning
		var position_line = PartyLinesControl.get_child(i)
		position_line.visible = true
		var position_marker = position_line.get_child(character.DefaultPosition) 
		var position_line_position = position_line.position
		var position_marker_position = position_marker.position
		character.position.x = (position_line_position.x + position_marker_position.x) - 1
		character.position.z = i * -3
		
	# Set up arrays, UI, and positioning for enemies
	for i in range(EnemyControlNode.get_child_count()):
		# Array
		var character = EnemyControlNode.get_child(i) as Enemy
		Enemies.append(character)
		BattleCharacters.append(character)
		
		# UI
		var new_ui = EnemyUI.instantiate() as CharacterUI
		new_ui.Character = character
		new_ui.set_label_name()
		new_ui.set_hp_max()
		new_ui.set_hp_current()
		new_ui.set_ap_max()
		new_ui.set_ap_current()
		EnemyUIContainer.add_child(new_ui)
		
		# Positioning
		var position_line = EnemyLinesControl.get_child(i)
		position_line.visible = true
		var position_marker = position_line.get_child(character.DefaultPosition)
		var position_line_position = position_line.position
		var position_marker_position = position_marker.position
		character.position.x = (position_line_position.x + position_marker_position.x) + 1
		character.position.z = i * -3
		
		
	# Sets up turn order and BattleCharacter array
	for i in range(BattleCharacters.size()):
		if i == 0:
			TurnOrder.append(BattleCharacters[i])
		else:
			var new_character = BattleCharacters[i]
			for j in range(TurnOrder.size()):
				var old_character = TurnOrder[j]
				if new_character.Speed > old_character.Speed:
					TurnOrder.insert(j, new_character)
				elif j >= TurnOrder.size() - 1:
					TurnOrder.append(new_character)
		BattleCharacters[i].TurnEnded.connect(end_turn)
					
	# Connects signals from all UI buttons
	for i in range(ActionMenuContainer.get_child_count()):
		var CurrentButton = ActionMenuContainer.get_child(i) as ActionMenuButton
		CurrentButton.cursor_selected.connect(_on_ability_button_pressed)
	for i in range(PartyUIContainer.get_child_count()):
		var CurrentButton = PartyUIContainer.get_child(i) as CharacterUI
		CurrentButton.cursor_selected.connect(_on_character_button_pressed)
		CurrentButton.cursor_focused.connect(_on_character_button_focused)
	for i in range(EnemyUIContainer.get_child_count()):
		var CurrentButton = EnemyUIContainer.get_child(i) as CharacterUI
		CurrentButton.cursor_selected.connect(_on_character_button_pressed)
		CurrentButton.cursor_focused.connect(_on_character_button_focused)
	for i in range(RepositionMenuContainer.get_child_count()):
		var CurrentButton = RepositionMenuContainer.get_child(i) as UIButton
		CurrentButton.cursor_selected.connect(_on_reposition_button_pressed)
	
	set_active_character(TurnOrder[0])

func set_active_character(character:BattleCharacter):
	ActiveCharacter = character
	character.add_child(TargetCursor)
	set_target_cursor_position(ActiveCharacter)
	
	if ActiveCharacter is PartyMember:
		Globals.UpdateGameState(Enums.GAME_STATE.BATTLE_MENU_NORMAL)
		MenuCursor.change_menu(ActionMenuContainer)
	elif ActiveCharacter is Enemy:
		Globals.UpdateGameState(Enums.GAME_STATE.BATTLE_ENEMY_TURN)
		ActiveCharacter.perform_turn(PartyMembers)
		
func set_target_cursor_position(character:BattleCharacter):
	TargetCursor.position = Vector3(character.position.x, character.position.y + 3, character.position.z + 6)
	TargetCursor.show()

func set_active_ability(ability:Ability):
	ActiveAbility = ability
	
func end_turn():
	# Send current character to the end of the turn order
	await get_tree().create_timer(3.0).timeout
	ActiveCharacter.HasRepositioned = false
	TurnOrder.append(TurnOrder.pop_front())
	set_active_character(TurnOrder[0])
	
func _on_ability_button_pressed():
	var ButtonPressed = ActionMenuContainer.get_child(MenuCursor.cursor_index) as ActionMenuButton
	set_active_ability(ButtonPressed.NextAbility)
	print(ButtonPressed.NextAbility)
	if ActiveAbility.AbilityName == "Reposition":
		if ActiveCharacter.HasRepositioned:
			var TextBox = TextBoxScene.instantiate()
			add_child(TextBox)
			TextBox.display_one_off_text(ActiveCharacter.BattlerName + " cannot reposition again this turn.")
		else:
			Globals.UpdateGameState(Enums.GAME_STATE.BATTLE_MENU_REPOSITION)
			RepositionMenuControl.show()
			MenuCursor.change_menu(RepositionMenuContainer)
			RepositionMenuControl.add_child(MenuCursor)
	elif ActiveAbility.TargetType == Enums.TARGET_TYPE.SINGLE:
		Globals.UpdateGameState(Enums.GAME_STATE.BATTLE_SELECTING_TARGET_ENEMY)
		MenuCursor.change_menu(EnemyUIContainer)
		EnemyUIControl.add_child(MenuCursor)
		
func _on_character_button_pressed():
	var ButtonPressed = EnemyUIContainer.get_child(MenuCursor.cursor_index) as CharacterUI
	TargetCharacter = ButtonPressed.Character
	
	# Checks if the enemy is out of range
	if ActiveAbility.AbilityName == "Ranged Attack":
		if (ActiveCharacter.CurrentPosition + TargetCharacter.CurrentPosition) >=2:
			ActiveAbility.perform_ability(ActiveCharacter, TargetCharacter, self)
			end_turn()
		else:
			var TextBox = TextBoxScene.instantiate()
			add_child(TextBox)
			TextBox.display_one_off_text(TargetCharacter.BattlerName + " is too close to use a " + ActiveAbility.AbilityName + ".")
	
func _on_character_button_focused():
	var character = Enemies[MenuCursor.cursor_index] as BattleCharacter
	set_target_cursor_position(character)
	
func _on_reposition_button_pressed():
	if MenuCursor.cursor_index == 0:
		if ActiveCharacter.CurrentPosition <= 1:
			ActiveCharacter.CurrentPosition += 1
		# Don't let the character move further backward if too far
		else:
			var TextBox = TextBoxScene.instantiate()
			add_child(TextBox)
			TextBox.display_reposition_failed_message(ActiveCharacter, "backward")
			return
	else:
		if ActiveCharacter.CurrentPosition >= 1:
			ActiveCharacter.CurrentPosition -= 1
		else:
			var TextBox = TextBoxScene.instantiate()
			add_child(TextBox)
			TextBox.display_reposition_failed_message(ActiveCharacter, "forward")
			return
	
	var position_line = PartyLinesControl.get_child(ActiveCharacter.get_index())
	var position_marker = position_line.get_child(ActiveCharacter.CurrentPosition)
	var position_line_position = position_line.position
	var position_marker_position = position_marker.position
	
	if ActiveCharacter is PartyMember:
		ActiveCharacter.position.x = (position_line_position.x + position_marker_position.x) - 1
	else:
		ActiveCharacter.position.x = (position_line_position.x + position_marker_position.x) + 1
	
	set_target_cursor_position(ActiveCharacter)
		
	ActiveCharacter.HasRepositioned = true
	RepositionMenuControl.hide()
	set_active_character(ActiveCharacter)
	
