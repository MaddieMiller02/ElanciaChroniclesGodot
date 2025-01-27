class_name Ability
extends Node

@export var AbilityName:String
@export var Description:String
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

func perform_ability(User:BattleCharacter, Target:BattleCharacter):
	print("Why did you perform a default ability?")
