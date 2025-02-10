class_name BattleCharacter
extends Node3D

signal HPChanged
signal APChanged
signal TurnEnded
signal HasDied

const Ability = preload("res://Scripts/BaseClasses/ability.gd")

@export var BattlerName:String
@export var Level:int
@export var IsDead:int = false
@export var EmittedDeathSignal:bool = false

@export var Strength:int #physical ability power
@export var Magic:int #magical ability power
@export var Defense:int #physical damage reduction
@export var Resistance:int #magical damage reduction
@export var Speed:int #determines starting turn order, ability to hit dodge physical attacks
@export var Charisma:int #ability to hit and dodge magic attacks, healing amount for non-magic healing
@export var EscapeSuccess:int

@export var TempHP:int
@export var TempAP:int
@export var TempDefense:int
@export var TempResistance:int
@export var CurrentHP:int
@export var CurrentAP:int
@export var MaxHP:int
@export var MaxAP:int

@export var HasRepositioned:bool = false

@export var SpecialsNode:Node
@export var SpecialList:Array[Ability]

@export var Statuses:Array[Enums.STATUS]
@export var StatusImmunities:Array[Enums.STATUS]

@export var DefaultPosition:int
@export var CurrentPosition:int

@export var Resistances:Array[Enums.ELEMENT]
@export var Weaknesses:Array[Enums.ELEMENT]

@export var Experience:int

func _ready() -> void:
	# Appends every child of the "Specials" node to the SpecialList
	if SpecialsNode != null:
		for i in range(SpecialsNode.get_child_count()):
			SpecialList.append(SpecialsNode.get_child(i))

func _process(delta):
	# Checks if the character has died
	if CurrentHP <= 0 and not EmittedDeathSignal:
		emit_signal("HasDied")
		EmittedDeathSignal = true
		IsDead = true
		self.hide()

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
	
func regain_ap(amount:int):
	CurrentAP += amount
	if CurrentAP >= MaxAP:
		CurrentAP = MaxAP
	APChanged.emit()
	
func reset_temp_stats():
	# Currently only accomadates one-turn stat buffs (like the ones granted by Defend)
	TempDefense = 0
	TempResistance = 0
