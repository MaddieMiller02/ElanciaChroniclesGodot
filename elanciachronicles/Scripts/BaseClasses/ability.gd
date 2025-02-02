class_name Ability
extends Node

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

var TextBoxScene = preload("res://Scenes/UI/BattleTextBox.tscn")

func perform_ability(User:BattleCharacter, Target:BattleCharacter, CurrentManager:BattleManager):
	print("Why did you perform a default ability?")

func in_range(User:BattleCharacter, Target:BattleCharacter) -> bool:
	var Distance = User.CurrentPosition + Target.CurrentPosition
	if MaxRange >= Distance and Distance >= MinRange:
		return true
	else:
		return false
