extends Node

var player;
var max_loot = 100;
var loot_count = 0;

var chest_reference = preload("res://loot/chest.tscn")
#region LootArrays
var mundane_array = [preload("res://potions/water.tres")]

var common_array = [preload("res://potions/health_potion.tres"), preload("res://potions/fire_breathing.tres"), preload("res://potions/water.tres"), preload("res://potions/empty_potion.tres"), preload("res://potions/slowness.tres")]

var uncommon_array = [preload("res://potions/water.tres")]

var rare_array = [preload("res://potions/water.tres")]

var epic_array = [preload("res://potions/water.tres")]

var legendary_array = [preload("res://potions/pitcher_potion.tres"), preload("res://potions/tankiness.tres"), preload("res://potions/swiftness_potion.tres")]

var unique_array = [preload("res://potions/water.tres")]
#endregion

func register_player(_player):
	player = _player

func get_loot(_type, _special = "default"): #returns loot of requested type
	match _type:
		"gold":
			return _special
		"chest":
			return chest_reference
		"mundane":
			var roll = randi() % mundane_array.size()
			return mundane_array[roll]
		"common":
			var roll = randi() % common_array.size()
			return common_array[roll]
		"uncommon":
			var roll = randi() % uncommon_array.size()
			return uncommon_array[roll]
		"rare":
			var roll = randi() % rare_array.size()
			return rare_array[roll]
		"epic":
			var roll = randi() % epic_array.size()
			return epic_array[roll]
		"legendary":
			var roll = randi() % legendary_array.size()
			return legendary_array[roll]
		"unique": 
			var roll = randi() % unique_array.size()
			return unique_array[roll]
