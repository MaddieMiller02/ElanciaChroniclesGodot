class_name SpecialContainer
extends UIButton

@export var NextAbility:Ability
@export var NameLabel:Label
@export var APCostLabel:Label

func setup(NewAbility:Ability):
	NextAbility = NewAbility
	NameLabel.text = NextAbility.AbilityName
	APCostLabel.text = str(NextAbility.APCost) + " AP"
