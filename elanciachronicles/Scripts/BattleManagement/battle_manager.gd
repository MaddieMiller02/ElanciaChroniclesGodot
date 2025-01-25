extends Node3D

var PartyMemberUI = preload("res://Scenes/UI/PartyMemberUI.tscn")
var EnemyUI = preload("res://Scenes/UI/EnemyUI.tscn")

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
@export var RangedAttackButton:ActionMenuButton

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
		character.position.x = (position_line_position.x + position_marker_position.x) + 3
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
		character.position.x = (position_line_position.x + position_marker_position.x) - 3
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
					
	# Connects signals from all UI buttons
	for i in range(ActionMenuContainer.get_child_count()):
		var CurrentButton = ActionMenuContainer.get_child(i) as ActionMenuButton
		CurrentButton.cursor_selected.connect(_on_ability_button_pressed)
	for i in range(PartyUIContainer.get_child_count()):
		var CurrentButton = PartyUIContainer.get_child(i) as CharacterUI
		CurrentButton.cursor_selected.connect(_on_character_button_pressed)
	for i in range(EnemyUIContainer.get_child_count()):
		var CurrentButton = EnemyUIContainer.get_child(i) as CharacterUI
		CurrentButton.cursor_selected.connect(_on_character_button_pressed)
	
	set_active_character(TurnOrder[0])

func set_active_character(character:BattleCharacter):
	ActiveCharacter = character
	character.add_child(TargetCursor)
	set_target_cursor_position(ActiveCharacter)
	
	if ActiveCharacter is PartyMember:
		Globals.UpdateGameState(Enums.GAME_STATE.BATTLE_MENU_NORMAL)
	elif ActiveCharacter is Enemy:
		# Activate enemy turn
		pass
		
func set_target_cursor_position(character:BattleCharacter):
	TargetCursor.position = Vector3(character.position.x, character.position.y + 3, character.position.z + 6)
	TargetCursor.show()

func set_active_ability(ability:Ability):
	ActiveAbility = ability
	
# TODO END OF TURN ACTIONS
	# Destroy the CharacterCursor
	# Put character at the end of TurnOrder
	
func _on_ability_button_pressed():
	var ButtonPressed = ActionMenuContainer.get_child(MenuCursor.cursor_index) as ActionMenuButton
	set_active_ability(ButtonPressed.NextAbility)
	if ActiveAbility.TargetType == Enums.TARGET_TYPE.SINGLE:
		Globals.UpdateGameState(Enums.GAME_STATE.BATTLE_SELECTING_TARGET_ENEMY)
		MenuCursor.menu_parent = EnemyUIContainer
		EnemyUIControl.add_child(MenuCursor)
		
func _on_character_button_pressed():
	var ButtonPressed = EnemyUIContainer.get_child(MenuCursor.cursor_index) as CharacterUI
	TargetCharacter = ButtonPressed.Character
	ActiveAbility.perform_ability(ActiveCharacter, TargetCharacter)
	
