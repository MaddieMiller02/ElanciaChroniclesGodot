class_name CharacterUI
extends UIButton

@export var Character:BattleCharacter
@export var NameLabel:Label
@export var HPBar:ProgressBar
@export var APBar:ProgressBar

func _ready():
	super._ready()
	Character.HPChanged.connect(set_hp_current)
	Character.APChanged.connect(set_ap_current)

func set_label_name():
	NameLabel.text = Character.BattlerName
	
func set_hp_max():
	HPBar.max_value = Character.MaxHP
	
func set_hp_current():
	HPBar.value = Character.CurrentHP
	
func set_ap_max():
	APBar.max_value = Character.MaxAP

func set_ap_current():
	APBar.value = Character.CurrentAP
