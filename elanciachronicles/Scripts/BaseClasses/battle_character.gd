class_name BattleCharacter
extends Node3D

signal HPChanged
signal APChanged
signal TurnEnded
signal HasDied
signal WeaknessHitSignal

const Ability = preload("res://Scripts/BaseClasses/ability.gd")
const TextBoxScene = preload("res://Scenes/UI/BattleTextBox.tscn")

@export var BattlerName:String
@export var Level:int
@export var IsDead:int = false
@export var EmittedDeathSignal:bool = false

@export var UIHexIcon:Texture2D

@export var WeaknessHit:bool = false

@export var Strength:int #physical ability power
@export var Magic:int #magical ability power
@export var Defense:int #physical damage reduction
@export var Resistance:int #magical damage reduction
@export var Speed:int #determines starting turn order, ability to hit dodge physical attacks
@export var Charisma:int #ability to hit and dodge magic attacks, healing amount for non-magic healing
@export var EscapeSuccess:int

@export var TempHP:int
@export var TempAP:int
@export var TempStrength:int
@export var TempMagic:int
@export var TempDefense:int
@export var TempResistance:int
@export var TempSpeed:int
@export var TempCharisma:int
@export var CurrentHP:int
@export var CurrentAP:int
@export var MaxHP:int
@export var MaxAP:int

@export var HasRepositioned:bool = false
@export var HasFollowedUp:bool = false

@export var SpecialsNode:Node
@export var SpecialList:Array[Ability]

@export var Statuses:Array[Enums.STATUS]
@export var StatusImmunities:Array[Enums.STATUS]

@export var DefaultPosition:int
@export var CurrentPosition:int

@export var Resistances:Array[Enums.ELEMENT]
@export var Weaknesses:Array[Enums.ELEMENT]

@export var Experience:int

#Animations
@export var Animator:AnimationTree

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

func turn_started():
	WeaknessHit = false

func take_damage(damage:int):
	CurrentHP -= damage
	if CurrentHP < 0:
		CurrentHP = 0
	HPChanged.emit()
	
	# Animate character taking damage
	if Animator != null:
		Animator.set("parameters/conditions/Damaged", true)
		await get_tree().create_timer(1.0).timeout
		Animator.set("parameters/conditions/Damaged", false)	
	
func heal(damage:int):
	CurrentHP += damage
	if CurrentHP > MaxHP:
		CurrentHP = MaxHP
	HPChanged.emit()
	
func weakness_check(Attack:Ability) -> bool:
	if Attack.Element in Weaknesses:
		WeaknessHit = true
		WeaknessHitSignal.emit()
		return true
	return false

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
	TempStrength = 0
	TempMagic = 0
	TempDefense = 0
	TempResistance = 0
	TempSpeed = 0
	TempCharisma = 0

func follow_up_boost(PowerLevel:int):
	# TODO: REWORK ALL STATS INTO TUPLES WITH A NAME AND A VALUE. THESE IF STATEMENTS ARE A TEMPORARY FIX
	if BattlerName == "Verse":
		TempSpeed += (PowerLevel * 2)
		TempMagic += (PowerLevel * 2)
		var TextBox = TextBoxScene.instantiate()
		add_child(TextBox)
		TextBox.display_one_off_text("Turn passed! Verse's Speed and Magic temporarily powered up!")
	if BattlerName == "Xan":
		TempStrength += (PowerLevel * 2)
		TempDefense += (PowerLevel * 2)
		var TextBox = TextBoxScene.instantiate()
		add_child(TextBox)
		TextBox.display_one_off_text("Turn passed! Xan's Strength and Defense temporarily powered up!")
		

# These Getters return the "active" value of each stat, those being the default value plus the temp value
func get_strength() -> int:
	return Strength + TempStrength

func get_magic() -> int:
	return Magic + TempMagic
	
func get_defense() -> int:
	return Defense + TempDefense

func get_resistance() -> int:
	return Resistance + TempResistance

func get_speed() -> int:
	return Speed + TempSpeed
	
func get_charisma() -> int:
	return Charisma + TempCharisma
