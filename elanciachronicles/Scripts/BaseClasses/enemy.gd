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

var SpecialList:Array[Ability]

var Statuses:Array[String]
var StatusImmunities:Array[String]

var DefaultPosition:String

var Resistances:Array[String]
var Weaknesses:Array[String]

var Experience:int
var DroppedItems:Dictionary
