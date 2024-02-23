extends Resource

class_name Potion

@export var name: String = ""
@export var rarity: String = ""
@export var satiation: int = 10
@export var id: int = 0
@export var texture: Texture2D
@export var color: Color

func effect(_player):
	print("Metabolizing: " + name)
	match id:
		2:
			_player.health += 1
			_player.health_update.emit(_player.health)
		4: 
			var fire_breath = preload("res://art/Effects/fire_breath.tscn").instantiate()
			fire_breath.position = _player.get_node("Head").position
			_player.add_child(fire_breath)
		5: 
			_player.speed -= 100
			_player.dodge_speed -= 100
			if _player.speed < 0:
				_player.speed = 0
			if _player.dodge_speed < 0:
				_player.dodge_speed = 0
