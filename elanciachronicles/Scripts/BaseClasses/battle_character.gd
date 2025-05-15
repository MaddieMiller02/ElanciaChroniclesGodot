class_name BattleCharacter
extends Node3D

signal HPChanged
signal APChanged
signal TurnEnded
signal HasDied
signal WeaknessHitSignal
signal DestinationReachedSignal

const Ability = preload("res://Scripts/BaseClasses/ability.gd")
const TextBoxScene = preload("res://Scenes/UI/BattleTextBox.tscn")

@export var BattlerName:String
@export var Level:int
@export var IsDead:int = false
@export var EmittedDeathSignal:bool = false

@export var UIHexIcon:Texture2D

@export var WeaknessHit:bool = false
@export var IsDefending:bool = false

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
@export var CharacterModel:Node3D
@export var Animator:AnimationTree
var Destination:Vector3
@export var DestinationReached:bool = true
var DamagedAnimation1:bool = false
var DamagedAnimation2:bool = false
var DamagedAnimation3:bool = false

# Camera points
@export var DefaultCamera:Camera3D
@export var ImpactCamera1:Camera3D
@export var ImpactCamera2:Camera3D

# Sound Effects
@export var MeleeSFX:AudioStreamPlayer3D
@export var LightSoundDelay:float
@export var MediumSoundDelay:float
@export var HeavySoundDelay:float
@export var RangedSFX:AudioStreamPlayer3D
@export var RangedSoundDelay:float
@export var RunSFX:AudioStreamPlayer3D
@export var StepDelay:bool
@export var DodgeSFX:AudioStreamPlayer3D
@export var HealSFX:AudioStreamPlayer3D
@export var HealSoundDelay:float
@export var DeathSFX:AudioStreamPlayer3D
var DeathSFXPlayed:bool = false
var PlayDeathAnimation:bool = false

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
		
	# Move to destination and animate if applicable
	if not DestinationReached:
		Animator.set("parameters/conditions/stopped", false)
		Animator.set("parameters/conditions/running", true)
		look_at(global_position + position.direction_to(Destination), Vector3.UP)
		if self is PartyMember:
			rotate_y(deg_to_rad(90))
		else:
			rotate_y(deg_to_rad(-90))
		if not StepDelay:
			run_sound_with_delay()
		position += position.direction_to(Destination) * 10 * delta
		if position.distance_to(Destination) < 0.3:
			position = Destination
			rotation = Vector3.ZERO
			await get_tree().create_timer(0.01).timeout
			DestinationReached = true
			DestinationReachedSignal.emit()
	else:
		Animator.set("parameters/conditions/running", false)
		Animator.set("parameters/conditions/stopped", true)
			
	#print(BattlerName + str(DestinationReached))

func turn_started():
	WeaknessHit = false

func take_damage(damage:int):
	CurrentHP -= damage
	if CurrentHP < 0:
		CurrentHP = 0
	HPChanged.emit()	
	
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
		

func damage_animation():
	# Animate character taking damage
	if Animator != null and !IsDefending:
		if IsDead:
			Animator.set("parameters/conditions/Died", true)
			print("Death animation triggered")
			if DeathSFX != null and !DeathSFXPlayed:
				DeathSFX.play()
				DeathSFXPlayed = true
			PlayDeathAnimation = true
			await Animator.animation_finished
		elif DamagedAnimation1 != true:
			print("Damage animation 1 triggered")
			DamagedAnimation1 = true
			Animator.set("parameters/conditions/Damaged", true)
		elif DamagedAnimation2 != true:
			print("Damage animation 2 triggered")
			DamagedAnimation2 = true
			Animator.set("parameters/conditions/Damage 2", true)
		else:
			print("Damage animation 3 triggered")
			DamagedAnimation3 = true
			Animator.set("parameters/conditions/Damage 3", true)
		
func reset_damage_animations():
	DamagedAnimation1 = false
	DamagedAnimation2 = false
	DamagedAnimation3 = false 
	Animator.set("parameters/conditions/Damaged", false)
	Animator.set("parameters/conditions/Damage 2", false)
	Animator.set("parameters/conditions/Damage 3", false)
	print("Damage animations reset!")

# Set destination and trigger movement in _process
func set_destination(NewDestination:Vector3):
	DestinationReached = false
	Destination = NewDestination
	
# Waits the alloted delay, then plays the corresponding sound
func light_melee_sound():
	await get_tree().create_timer(LightSoundDelay).timeout
	MeleeSFX.play()
	
func medium_melee_sound():
	await get_tree().create_timer(MediumSoundDelay).timeout
	MeleeSFX.play()
	
func heavy_melee_sound():
	await get_tree().create_timer(HeavySoundDelay).timeout
	MeleeSFX.play()
	
func ranged_sound():
	await get_tree().create_timer(RangedSoundDelay).timeout
	RangedSFX.play()

func run_sound_with_delay():
	StepDelay = true
	RunSFX.play()
	await get_tree().create_timer(0.3333).timeout
	StepDelay = false
	
func dodge_sound():
	DodgeSFX.play()
	
func heal_sound():
	await get_tree().create_timer(HealSoundDelay).timeout
	HealSFX.play()

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

func get_destination_reached() -> bool:
	return DestinationReached
	
func get_is_dead() -> bool:
	return IsDead
	
func get_is_defending() -> bool:
	return IsDefending
	
func get_play_death_animation() -> bool:
	return PlayDeathAnimation
