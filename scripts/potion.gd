extends Resource

class_name Potion

@export var name: String = ""
@export var rarity: String = ""
@export var description: String = "" #Displayed for Legendaries
@export var satiation: int = 10 #How much thirst is restored
@export var texture: Texture2D
@export var color: Color #Floor Opacity, usually 100

func effect(_player):
	print("Metabolizing: " + name)
	match name:
		"Health Potion":
			_player.health += 1
			_player.health_update.emit(_player.health)
		"Potion of Fire Breathing": 
			var fire_breath = preload("res://scenes/effect_scenes/fire_breath.tscn")
			fire_breath.position = _player.get_node("Head").position
			_player.add_child(fire_breath)
		"Potion of Slowness": 
			_player.speed -= 100
			_player.dodge_speed -= 100
			if _player.speed < 0:
				_player.speed = 0
			if _player.dodge_speed < 0:
				_player.dodge_speed = 0
		"Swiftness Potion": 
			_player.speed += 300
			_player.dodge_speed += 300
		"Pitcher Potion": 
			_player.throw_speed += 500
		"Potion of Tankiness":
			_player.speed -= 100
			_player.max_health += 1
			_player.health += 1
