class_name Ability
extends Node

signal AbilityFinished

@export var AbilityName:String
@export var Description:String
@export var MinRange:int
@export var MaxRange:int
@export var Power:int
@export var Physical:bool
@export var IgnoreDefense:bool
@export var HitRate:int
@export var APCost:int
@export var Reflectable:bool
@export var DamageMultiplier:float
@export var TargetType:Enums.TARGET_TYPE
@export var StatusEffects:Array[Enums.STATUS]
@export var Element:Enums.ELEMENT
@export var IsActive:bool
@export var OriginalPosition:Vector3

var TextBoxScene = preload("res://Scenes/UI/BattleTextBox.tscn")

func perform_ability(User:BattleCharacter, Target:BattleCharacter, CurrentManager:BattleManager):
	print("Why did you perform a default ability?")

func in_range(User:BattleCharacter, Target:BattleCharacter) -> bool:
	var Distance = User.CurrentPosition + Target.CurrentPosition
	if MaxRange >= Distance and Distance >= MinRange:
		return true
	else:
		return false
		
func move_to_target(User:BattleCharacter, Target:BattleCharacter):
	# Move in front of the target
	if User is PartyMember:
		User.set_destination(Vector3(Target.position.x - 1.5, Target.position.y, Target.position.z))
	else:
		User.set_destination(Vector3(Target.position.x + 1.5, Target.position.y, Target.position.z))
	
func move_to_start(User:BattleCharacter, Target:BattleCharacter):
	# Move back to original position
	print(OriginalPosition)
	User.set_destination(OriginalPosition)
