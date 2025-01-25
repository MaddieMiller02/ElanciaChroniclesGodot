class_name BattleCharacter
extends Node3D

signal HPChanged
signal APChanged

const Ability = preload("res://Scripts/BaseClasses/ability.gd")

@export var BattlerName:String
@export var Level:int

@export var Strength:int #physical ability power
@export var Magic:int #magical ability power
@export var Defense:int #physical damage reduction
@export var Resistance:int #magical damage reduction
@export var Speed:int #determines starting turn order, ability to hit dodge physical attacks
@export var Charisma:int #ability to hit and dodge magic attacks, healing amount for non-magic healing
@export var EscapeSuccess:int

@export var TempHP:int
@export var TempAP:int
@export var CurrentHP:int
@export var CurrentAP:int
@export var MaxHP:int
@export var MaxAP:int

@export var SpecialList:Array[Ability]

@export var Statuses:Array[Enums.STATUS]
@export var StatusImmunities:Array[Enums.STATUS]

@export var DefaultPosition:int
@export var CurrentPosition:int

@export var Resistances:Array[Enums.ELEMENT]
@export var Weaknesses:Array[Enums.ELEMENT]

@export var Experience:int

func take_damage(damage:int):
	CurrentHP -= damage
	if CurrentHP < 0:
		CurrentHP = 0
	HPChanged.emit()
	
func use_ap(amount:int):
	CurrentAP -= amount
	if CurrentAP < 0:
		CurrentAP = 0
	APChanged.emit()
