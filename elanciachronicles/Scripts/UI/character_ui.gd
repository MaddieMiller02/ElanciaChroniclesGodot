class_name CharacterUI
extends UIButton

@export var Character:BattleCharacter
@export var NameLabel:Label
@export var HPLabel:Label
@export var APLabel:Label
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
	update_hp_label()
	
func set_hp_current():
	HPBar.value = Character.CurrentHP
	update_hp_label()
	
func set_ap_max():
	APBar.max_value = Character.MaxAP
	update_ap_label()

func set_ap_current():
	APBar.value = Character.CurrentAP
	update_ap_label()

func update_hp_label():
	HPLabel.text = (str(Character.CurrentHP) + "/" + str(Character.MaxHP))
	
func update_ap_label():
	APLabel.text = (str(Character.CurrentAP) + "/" + str(Character.MaxAP))
