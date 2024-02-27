extends Node2D

var heart_scene = preload("res://scenes/hud/heart.tscn")

var max_health = 0
var health = max_health
var heart_array = []
var spacing = 100

func _ready():
	print("READY")
	adjust_hp(3, 3)

func display_health():
	print("DISPLAY")
	var hp = health
	var count = 0
	for i in heart_array:
		print("i: " + str(i) + " count " + str(count) + " hp: " + str(hp) + " max: " + str(max_health))
		i.set_zero()
		hp = i.add_hp(hp)
		print("hp: " + str(hp))
		i.position = Vector2(1,0)*spacing*count
		count += 1

func adjust_hp(_health, _max_health):
	health = _health
	if max_health > _max_health:
		heart_array.resize(max_health)
		max_health = _max_health
	while max_health < _max_health:
		var heart = heart_scene.instantiate()
		add_child(heart)
		heart_array.append(heart)
		max_health += 1
	assert(max_health == _max_health)
	
	display_health()
