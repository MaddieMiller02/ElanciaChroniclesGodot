class_name BattleManager
extends Node3D

const PartyMemberUI = preload("res://Scenes/UI/PartyMemberUI.tscn")
const EnemyUI = preload("res://Scenes/UI/EnemyUI.tscn")
const TextBoxScene = preload("res://Scenes/UI/BattleTextBox.tscn")
const TargetCursorScene = preload("res://Scenes/UI/TargetCursor.tscn")
const SpecialContainerScene = preload("res://Scenes/UI/SpecialContainer.tscn")

@export var PartyControlNode:Node
var PartyMembers:Array[PartyMember]
@export var EnemyControlNode:Node
var Enemies:Array[Enemy]
var BattleCharacters:Array[BattleCharacter]

var FollowUpInitiator:BattleCharacter
var FollowUpPrompt:bool = false
var FollowUpLevel:int = 0
var TurnOrder:Array[BattleCharacter]
var AttackQueue :Array[Ability]

var ActiveCharacter:BattleCharacter
var ActiveAbility:Ability
var TargetCharacter:BattleCharacter

@export var PartyUIControl:Node
@export var PartyUIContainer:Container
@export var EnemyUIControl:Node
@export var EnemyUIContainer:Container
@export var TurnOrderUIContainer:Container

@export var ActionMenuContainer:Container
@export var MeleeMenuContainer:Container
@export var MeleeMenuControl:Node
@export var RangedAttackButton:ActionMenuButton
@export var SpecialMenuContainer:Container
@export var SpecialMenuControl: Node
@export var SpecialDescriptionBox: Label
@export var RepositionMenuControl:Node
@export var RepositionMenuContainer:Container
@export var RepositionButton:ActionMenuButton
@export var FollowUpMenuControl:Node
@export var FollowUpMenuContainer:Container
@export var AbilityPanelControl:Node

@export var PartyLinesControl:Node
@export var EnemyLinesControl:Node

@export var MenuCursor:MenuCursor

@export var TargetCursor:Node3D

# Camera variables
@export var PlayerTurnCamera:Camera3D

# Music references
@export var BattleMusic:AudioStreamPlayer
@export var VictoryMusic:AudioStreamPlayer
@export var DefeatMusic:AudioStreamPlayer

func _ready():
	Globals.UpdateGameState(Enums.GAME_STATE.BATTLE)
	Globals.GameStateUpdated.connect(_on_game_state_changed)
	
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
					break
				elif j >= TurnOrder.size() - 1:
					TurnOrder.append(new_character)
					break
		BattleCharacters[i].TurnEnded.connect(_on_end_turn)
		BattleCharacters[i].HasDied.connect(_on_character_died)
		BattleCharacters[i].WeaknessHitSignal.connect(_on_weakness_hit)
		
					
	# Sets up the Turn Order UI
	for i in range(TurnOrder.size()):
		var NewHex = TextureRect.new()
		NewHex.texture = TurnOrder[i].UIHexIcon
		TurnOrderUIContainer.add_child(NewHex)
	
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
	for i in range(MeleeMenuContainer.get_child_count()):
		var CurrentButton = MeleeMenuContainer.get_child(i) as ActionMenuButton
		CurrentButton.cursor_selected.connect(_on_melee_type_button_pressed)
	for i in range(FollowUpMenuContainer.get_child_count()):
		var CurrentButton = FollowUpMenuContainer.get_child(i) as UIButton
		CurrentButton.cursor_selected.connect(_on_follow_up_button_pressed)
	
	set_active_character(TurnOrder[0])

func _process(delta):
	if Input.is_action_just_pressed("reset"):
			get_tree().change_scene_to_file("res://Scenes/TestScenes/battle_template.tscn")

func set_active_character(character:BattleCharacter):
	# If all enemies have been defeated, end the battle
	if Enemies.size() <= 0:
		Globals.UpdateGameState(Enums.GAME_STATE.BATTLE_WON)
		return
		
	elif PartyMembers.size() <= 0:
		Globals.UpdateGameState(Enums.GAME_STATE.BATTLE_LOST)
		return
	
	AttackQueue.clear()
	#if ActiveAbility != null:
		#await ActiveAbility.AbilityFinished
	
	# Resets temporary stat buffs at the start of the next turn
	FollowUpPrompt = false
	
	# Set the new active character
	ActiveCharacter = character
	ActiveCharacter.turn_started()
	
	if ActiveCharacter.HasFollowedUp == false:
		ActiveCharacter.reset_temp_stats()
		print(ActiveCharacter.BattlerName + "'s temporary stats reset!")
	
	# If this character started a follow up chain in the previous round, reset the turn order
	if ActiveCharacter == FollowUpInitiator:
		FollowUpInitiator = null;
		
		# Reset the turn order, Follow Up Level, and all characters' HasFollowedUp markers and temp stats
		TurnOrder.clear()
		TurnOrder.append(ActiveCharacter)
		FollowUpLevel = 0
		
		var SlowerCharacters:Array[BattleCharacter]
		var FasterCharacters:Array[BattleCharacter]
		
		# Determine the speed order based on the current active character, with slower characters going immediately after, and faster characters going after them.
		for i in range(BattleCharacters.size()):
			var Character = BattleCharacters[i]
			Character.HasFollowedUp = false
			
			# Sort chararacters into sepearate arrays of "faster" and "slower" characters
			if Character != ActiveCharacter:
				if Character.get_speed() <= ActiveCharacter.get_speed():
					SlowerCharacters.append(Character)
				else:
					FasterCharacters.append(Character)
				
		# Sort these lists based on speed, in decreasing order
		for i in range(SlowerCharacters.size()):
			for j in range(i, SlowerCharacters.size()):
				if SlowerCharacters[i].get_speed() < SlowerCharacters[j].get_speed():
					SlowerCharacters.insert(j, SlowerCharacters.pop_at(i))
					
		for i in range(FasterCharacters.size()):
			for j in range(i, FasterCharacters.size()):
				if FasterCharacters[i].get_speed() < FasterCharacters[j].get_speed():
					FasterCharacters.insert(j, FasterCharacters.pop_at(i))
					
		# Append everything from the SlowerCharacters list to the Turn Order, then do the same for the Faster Characters
		for i in range(SlowerCharacters.size()):
			TurnOrder.append(SlowerCharacters[i])
		for i in range(FasterCharacters.size()):
			TurnOrder.append(FasterCharacters[i])
					
		# Reset the UI
		build_turn_order_ui()
	
		var TextBox = TextBoxScene.instantiate()
		add_child(TextBox)
		TextBox.display_one_off_text("Turn order reset!")
	
	if TargetCursor.get_parent().visible == false:
		TargetCursor = TargetCursorScene.instantiate()
	ActiveCharacter.add_child(TargetCursor)
	set_target_cursor_position(ActiveCharacter)
	
	# Deactivate defend animation
	if ActiveCharacter.Animator != null and ActiveCharacter.IsDefending:
		ActiveCharacter.Animator.set("parameters/conditions/Defend", true)
		await get_tree().create_timer(0.1).timeout
		ActiveCharacter.Animator.set("parameters/conditions/Defend", false)
		await get_tree().create_timer(0.4).timeout
	ActiveCharacter.IsDefending = false
	
	# Restore this character's AP by a small amount every turn
	ActiveCharacter.gain_passive_ap()
	
	if ActiveCharacter is PartyMember:
		Globals.UpdateGameState(Enums.GAME_STATE.BATTLE_MENU_NORMAL)
		MenuCursor.change_menu(ActionMenuContainer)
	elif ActiveCharacter is Enemy:
		Globals.UpdateGameState(Enums.GAME_STATE.BATTLE_ENEMY_TURN)
		ActiveCharacter.perform_turn(PartyMembers, self)
		
	MenuCursor.clear_previous_menus()
	
	# Set the camera position to the default
	#PlayerTurnCamera.make_current()
		
func set_target_cursor_position(Character:BattleCharacter):
	TargetCursor.position = Vector3(Character.position.x, Character.position.y + 2.5, Character.position.z + 6)
	TargetCursor.show()

func set_active_ability(ability:Ability):
	ActiveAbility = ability
	
func build_turn_order_ui():
	for i in range(TurnOrderUIContainer.get_child_count()):
		TurnOrderUIContainer.get_child(i).queue_free()
	for i in range(TurnOrder.size()):
		var NewHex = TextureRect.new()
		NewHex.texture = TurnOrder[i].UIHexIcon
		TurnOrderUIContainer.add_child(NewHex)

func _special_menu_setup():
	# Clears all previous special containers and resets the special menu
	for Special in SpecialMenuContainer.get_children():
		Special.queue_free()
	
	# Create new special menu, with special buttons for each special in the Active Character's SpecialList
	for i in range(ActiveCharacter.SpecialList.size()):
		var NewSpecialButton = SpecialContainerScene.instantiate()
		NewSpecialButton.setup(ActiveCharacter.SpecialList[i])
		NewSpecialButton.connect("cursor_focused", _on_special_button_focused)
		NewSpecialButton.connect("cursor_selected", _on_special_button_selected)
		SpecialMenuContainer.add_child(NewSpecialButton)

func _on_end_turn():
	if FollowUpPrompt == true and ActiveCharacter is PartyMember:
		
		Globals.UpdateGameState(Enums.GAME_STATE.BATTLE_MENU_FOLLOW_UP)
		
		var TextBox = TextBoxScene.instantiate()
		add_child(TextBox)
		TextBox.display_one_off_text("Would you like to pass your turn and perform a follow up?")
		
		MenuCursor.change_menu(FollowUpMenuContainer)
		MenuCursor.previous_menus.clear()
		FollowUpMenuControl.add_child(MenuCursor)
	else:
		# Send current character to the end of the turn order
		if ActiveCharacter.Animator == null:
			await get_tree().create_timer(3.0).timeout
		TurnOrder.append(TurnOrder.pop_front())
		
		# Begin the new character's turn
		TurnOrderUIContainer.move_child(TurnOrderUIContainer.get_child(0), -1)
		set_active_character(TurnOrder[0])
		
	ActiveCharacter.HasRepositioned = false
		
func _on_character_died():
	for i in range(BattleCharacters.size()):
		if BattleCharacters[i].CurrentHP == 0:
			var DeadCharacter = BattleCharacters[i]
			var DeadCharacterIndex = TurnOrder.find(DeadCharacter)
			
			#TODO: REMOVE THIS CHARACTER'S ROW FROM VIEW
			
			TurnOrder.pop_at(DeadCharacterIndex)
			BattleCharacters.pop_at(i)
			build_turn_order_ui()
			
			if DeadCharacter is PartyMember:
				DeadCharacterIndex = PartyMembers.find(DeadCharacter)
				PartyMembers.pop_at(DeadCharacterIndex)
				for j in range(PartyUIContainer.get_child_count()):
					if (PartyUIContainer.get_child(j) as CharacterUI).Character == DeadCharacter:
						PartyUIContainer.get_child(j).queue_free()
				
			else:
				DeadCharacterIndex = Enemies.find(DeadCharacter)
				Enemies.pop_at(DeadCharacterIndex)
				
				# Remove character from UI
				for j in range(EnemyUIContainer.get_child_count()):
					if (EnemyUIContainer.get_child(j) as CharacterUI).Character == DeadCharacter:
						EnemyUIContainer.get_child(j).queue_free()
			
			return
	
func _on_ability_button_pressed():
	var ButtonPressed = ActionMenuContainer.get_child(MenuCursor.cursor_index) as ActionMenuButton
	set_active_ability(ButtonPressed.NextAbility)
	
	if ActiveAbility == null:
		var TextBox = TextBoxScene.instantiate()
		add_child(TextBox)
		TextBox.display_one_off_text("You don't have any items right now!")
		return
	
	# If the character does not have enough AP for an attack, do not let them proceed
	if ActiveAbility.APCost > ActiveCharacter.CurrentAP:
		var TextBox = TextBoxScene.instantiate()
		add_child(TextBox)
		TextBox.display_one_off_text("Not enough AP!")
	else:
		if ActiveAbility.AbilityName == "Reposition":
			# Do not let the character reposition if they already have this turn
			if ActiveCharacter.HasRepositioned:
				var TextBox = TextBoxScene.instantiate()
				add_child(TextBox)
				TextBox.display_one_off_text(ActiveCharacter.BattlerName + " cannot reposition again this turn.")
				return
			# Otherwise, change to the reposition menu
			else:
				Globals.UpdateGameState(Enums.GAME_STATE.BATTLE_MENU_REPOSITION)
				RepositionMenuControl.show()
				MenuCursor.change_menu(RepositionMenuContainer)
				RepositionMenuControl.add_child(MenuCursor)
				return
		elif ActiveAbility.AbilityName == "Defend":
			Globals.UpdateGameState(Enums.GAME_STATE.BATTLE_ANIMATING)
			await ActiveAbility.perform_ability(ActiveCharacter, TargetCharacter, self)
			_on_end_turn()
			return
		elif ActiveAbility.AbilityName == "Special":
			Globals.UpdateGameState(Enums.GAME_STATE.BATTLE_MENU_SPECIALS)
			_special_menu_setup()
			SpecialMenuControl.show()
			MenuCursor.change_menu(SpecialMenuContainer)
			SpecialMenuControl.add_child(MenuCursor)
			return
		
		# Melee and Ranged attacks should have this target type, and go straight to the target selection menu
		if ActiveAbility.TargetType == Enums.TARGET_TYPE.SINGLE:
			Globals.UpdateGameState(Enums.GAME_STATE.BATTLE_SELECTING_TARGET_ENEMY)
			MenuCursor.change_menu(EnemyUIContainer)
			EnemyUIControl.add_child(MenuCursor)
		
func _on_character_button_pressed():
	var ButtonPressed = MenuCursor.get_menu_item_at_index(MenuCursor.cursor_index) as CharacterUI
	TargetCharacter = ButtonPressed.Character
	
	# Checks if the enemy is out of range or dead, performs ability otherwise
	if not TargetCharacter.IsDead:
		# If the character is trying to pass a turn, perform this action instead of anything else
		if FollowUpPrompt == true:
			
			# Prevent the player from passing to the same character
			if TargetCharacter == ActiveCharacter:
				var TextBox = TextBoxScene.instantiate()
				add_child(TextBox)
				TextBox.display_one_off_text("You can't pass your turn to yourself!")
				return
				
			# Check if the character has already performed a Follow Up this round, and prevent them from passing if so
			if TargetCharacter.HasFollowedUp:
				var TextBox = TextBoxScene.instantiate()
				add_child(TextBox)
				TextBox.display_one_off_text("This character cannot follow up again until the turn order resets.")
				return
			
			# If this is the first character to initiate a follow up this round, store them for reseting the turn order later
			if FollowUpInitiator == null:
				FollowUpInitiator = ActiveCharacter
			
			# Send the current character to the end of the turn order
			TurnOrder.append(TurnOrder.pop_front())
			TurnOrderUIContainer.move_child(TurnOrderUIContainer.get_child(0), -1)
			
			# Find the new character's index, then put them at the front
			var CharacterIndex = TurnOrder.find(TargetCharacter)
			TurnOrder.insert(0, TurnOrder.pop_at(CharacterIndex))
			TurnOrderUIContainer.move_child(TurnOrderUIContainer.get_child(CharacterIndex), 0)
			
			# Mark that this character has Followed Up so they cannot do so again until the next round.
			ActiveCharacter.HasFollowedUp = true
			TargetCharacter.HasFollowedUp = true
			
			# Increases the Follow Up Level, and boosts the next character's stats accordingly
			FollowUpLevel += 1
			TargetCharacter.follow_up_boost(FollowUpLevel)
			
			# Begin the next turn
			set_active_character(TurnOrder[0])
			
		else:
			# Checks to ensure the enemy is not out of range, performs ability otherwise.
			if ActiveAbility.in_range(ActiveCharacter, TargetCharacter):
				if ActiveAbility.AbilityName == "Melee Attack":
					Globals.UpdateGameState(Enums.GAME_STATE.BATTLE_MENU_MELEE)
					MeleeMenuControl.show()
					MenuCursor.change_menu(MeleeMenuContainer)
					MeleeMenuControl.add_child(MenuCursor)
					var TextBox = TextBoxScene.instantiate()
					add_child(TextBox)
					TextBox.display_one_off_text("Choose three attacks.")
					return
				
				# Checks to see if this is a healing move, and stops the player from using it if the specified ally already has full health
				elif ActiveAbility.TargetType == Enums.TARGET_TYPE.SINGLE_ALLY:
					if TargetCharacter.CurrentHP == TargetCharacter.MaxHP:
						var TextBox = TextBoxScene.instantiate()
						add_child(TextBox)
						TextBox.display_one_off_text(TargetCharacter.BattlerName + " already has full health!")
						return
					else:
						Globals.UpdateGameState(Enums.GAME_STATE.BATTLE_ANIMATING)
						await ActiveAbility.perform_ability(ActiveCharacter, TargetCharacter, self)
						_on_end_turn()
						
				elif ActiveAbility.TargetType == Enums.TARGET_TYPE.SINGLE:
					await ActiveAbility.perform_ability(ActiveCharacter, TargetCharacter, self)
					Globals.UpdateGameState(Enums.GAME_STATE.BATTLE_ANIMATING)
					_on_end_turn()
			else:
				var TextBox = TextBoxScene.instantiate()
				add_child(TextBox)
				TextBox.display_one_off_text(TargetCharacter.BattlerName + " is out of range for a " + ActiveAbility.AbilityName + ".")
				return
	else:
		var TextBox = TextBoxScene.instantiate()
		add_child(TextBox)
		TextBox.display_one_off_text(TargetCharacter.BattlerName + " is knocked out!")
	
func _on_character_button_focused():
	# Determine whether the target is an enemy or a party member, and set the cursor accordingly
	var Character
	if ActiveAbility.TargetType == Enums.TARGET_TYPE.SINGLE_ALLY or FollowUpPrompt == true:
		if MenuCursor.cursor_index < PartyMembers.size():
			Character = PartyMembers[MenuCursor.cursor_index] as BattleCharacter
	elif ActiveAbility.TargetType == Enums.TARGET_TYPE.SINGLE:
		Character = Enemies[MenuCursor.cursor_index] as BattleCharacter
		
	if Character != null:
		set_target_cursor_position(Character)
	
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
	
func _on_melee_type_button_pressed():
	# If there are less than 3 attacks in the attack cue, append this attack to the queue
	if AttackQueue.size() <= 3:
		var CurrentButton = MenuCursor.get_menu_item_at_index(MenuCursor.cursor_index) as ActionMenuButton
		var ap_buffer = ActiveCharacter.CurrentAP - CurrentButton.NextAbility.APCost
		for i in range(AttackQueue.size()):
			ap_buffer -= AttackQueue[i].APCost
		print("AP Buffer: " + str(ap_buffer))
		if ap_buffer > (1 - AttackQueue.size()):
			AttackQueue.append(CurrentButton.NextAbility)
		else:
			var TextBox = TextBoxScene.instantiate()
			add_child(TextBox)
			TextBox.display_one_off_text("Not enough AP")
	if AttackQueue.size() == 3:
		Globals.UpdateGameState(Enums.GAME_STATE.BATTLE_ANIMATING)
		await ActiveAbility.perform_ability(ActiveCharacter, TargetCharacter, self)
		_on_end_turn()

func _on_special_button_focused():
	var CurrentSpecialContainer = MenuCursor.get_menu_item_at_index(MenuCursor.cursor_index) as SpecialContainer
	
func _on_special_button_selected():
	ActiveAbility = (MenuCursor.get_menu_item_at_index(MenuCursor.cursor_index) as SpecialContainer).NextAbility
	
	# Open the single-enemy targeting menu if attack target type is single and enemy
	if ActiveAbility.TargetType == Enums.TARGET_TYPE.SINGLE:
		Globals.UpdateGameState(Enums.GAME_STATE.BATTLE_SELECTING_TARGET_ENEMY)
		MenuCursor.change_menu(EnemyUIContainer)
		EnemyUIControl.add_child(MenuCursor)
			
	# For moves that target party members (such as healing moves like First Aid)
	elif ActiveAbility.TargetType == Enums.TARGET_TYPE.SINGLE_ALLY:
		Globals.UpdateGameState(Enums.GAME_STATE.BATTLE_SELECTING_TARGET_PARTY)
		MenuCursor.change_menu(PartyUIContainer)
		PartyUIControl.add_child(MenuCursor)

func _on_weakness_hit():
	if ActiveCharacter is PartyMember:
		FollowUpPrompt = true

func _on_follow_up_button_pressed():
	# If the player selects no, end turn as normal
	if MenuCursor.cursor_index == 0:
		FollowUpPrompt = false
		_on_end_turn()
		
	# Otherwise, prompt the player to select who they're passing their turn to.
	else:
		MenuCursor.cursor_index = 0
		MenuCursor.change_menu(PartyUIContainer)
		PartyUIControl.add_child(MenuCursor)
		Globals.UpdateGameState(Enums.GAME_STATE.BATTLE_SELECTING_TARGET_PARTY)
		
		
func _on_game_state_changed():
	if Globals.CurrentGameState == Enums.GAME_STATE.BATTLE_WON:
		BattleMusic.stop()
		VictoryMusic.play()
	elif Globals.CurrentGameState == Enums.GAME_STATE.BATTLE_LOST:
		BattleMusic.stop()
		DefeatMusic.play()
	set_target_cursor_position(ActiveCharacter)
