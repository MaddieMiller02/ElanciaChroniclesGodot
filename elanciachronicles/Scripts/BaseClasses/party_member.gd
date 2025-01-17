extends Node

const Ability = preload("res://Scripts/BaseClasses/ability.gd")

var BattlerName:String
var Level:int

var Strength:int #physical ability power
var Magic:int #magical ability power
var Defense:int #physical damage reduction
var Resistance:int #magical damage reduction
var Speed:int #determines starting turn order, ability to hit dodge physical attacks
var Charisma:int #ability to hit and dodge magic attacks, healing amount for non-magic healing
var EscapeSuccess:int

var TempHP:int
var TempSP:int
var CurrentHP:int
var CurrentSP:int
var MaxHP:int
var MaxSP:int

var InitialLevelOffset:int

var InParty:bool
var IsWounded:bool

var SpecialList:Array[Ability]
var SpecialActivationList:Dictionary

var Statuses:Array[Enums.STATUS]
var StatusImmunities:Array[Enums.STATUS]

var DefaultPosition:String
var IsPartyLeader:bool

var Resistances:Array[Enums.ELEMENT]
var Weaknesses:Array[Enums.ELEMENT]

var Experience:int
