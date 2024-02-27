extends CanvasLayer

var heart_scene = preload("res://scenes/hud/heart.tscn")

var max_health = 6
var health = max_health
var heart_array = [preload("res://scenes/hud/heart.tscn"), preload("res://scenes/hud/heart.tscn"), preload("res://scenes/hud/heart.tscn")]
var spacing = 20

func display_health():
	var hp = health
	for i in heart_array:
		hp = i.add_hp(hp)

func adjust_hp
