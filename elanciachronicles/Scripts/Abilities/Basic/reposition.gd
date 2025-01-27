extends Ability

func perform_ability(User:BattleCharacter, Target:BattleCharacter, CurrentManager:BattleManager):
	var position_line
	if User is PartyMember:
		if CurrentManager.MenuCursor.cursor_index == 0:
			if CurrentManager.ActiveCharacter.CurrentPosition <= 1:
				CurrentManager.ActiveCharacter.CurrentPosition += 1
			# Don't let the character move further backward if too far
			else:
				var TextBox = TextBoxScene.instantiate()
				add_child(TextBox)
				TextBox.display_reposition_failed_message(CurrentManager.ActiveCharacter, "backward")
				return
		else:
			if CurrentManager.ActiveCharacter.CurrentPosition >= 1:
				CurrentManager.ActiveCharacter.CurrentPosition -= 1
			else:
				var TextBox = TextBoxScene.instantiate()
				add_child(TextBox)
				TextBox.display_reposition_failed_message(CurrentManager.ActiveCharacter, "forward")
				return
		position_line = CurrentManager.PartyLinesControl.get_child(CurrentManager.ActiveCharacter.get_index())
	else:
		if CurrentManager.ActiveCharacter.CurrentPosition <= 1:
			CurrentManager.ActiveCharacter.CurrentPosition += 1
			var TextBox = TextBoxScene.instantiate() as BattleTextBox
			add_child(TextBox)
			TextBox.display_reposition_message(User, "Backward")
		else:
			CurrentManager.ActiveCharacter.CurrentPosition -= 1
			var TextBox = TextBoxScene.instantiate() as BattleTextBox
			add_child(TextBox)
			TextBox.display_reposition_message(User, "Forward")
		position_line = CurrentManager.EnemyLinesControl.get_child(CurrentManager.ActiveCharacter.get_index())
	
	var position_marker = position_line.get_child(CurrentManager.ActiveCharacter.CurrentPosition)
	var position_line_position = position_line.position
	var position_marker_position = position_marker.position
	
	if CurrentManager.ActiveCharacter is PartyMember:
		CurrentManager.ActiveCharacter.position.x = (position_line_position.x + position_marker_position.x) - 1
	else:
		CurrentManager.ActiveCharacter.position.x = (position_line_position.x + position_marker_position.x) + 1
	
	CurrentManager.set_target_cursor_position(CurrentManager.ActiveCharacter)
		
	CurrentManager.ActiveCharacter.HasRepositioned = true
	CurrentManager.RepositionMenuControl.hide()
