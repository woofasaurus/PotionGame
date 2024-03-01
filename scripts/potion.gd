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
			var fire_breath = preload("res://scenes/effect_scenes/fire_breath.tscn").instantiate()
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
		"The Strongest Potion":
			_player.health = -9999
		"Potion of Potion Seller":
			var potion_seller = load("res://scenes/npcs/potion_seller/potion_seller.tscn").instantiate()
			potion_seller.position = _player.position + Vector2(0,-400)
			potion_seller.scale *= 0.34
			_player.get_tree().current_scene.get_node("SortingLayer").add_child(potion_seller)
		"Potion of Misery":
			_player.health -= 1
		"Melee Potion":
			if _player.melee == true:
				_player.melee_scale += 1
			else:
				_player.melee = true;
		"Potion of Greed":
			for i in range (2):
				var loot = load("res://scenes/loot.tscn").instantiate()
				loot.global_position = _player.position
				_player.get_tree().current_scene.get_node("SortingLayer").add_child(loot)
				loot.set_loot("epic")
		"Potion of Elusiveness":
			_player.get_node("DodgeCooldown").wait_time *= 0.5
