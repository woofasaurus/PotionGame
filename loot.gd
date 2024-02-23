extends Area2D
var direction
var velocity
var spin
var potion_reference
var is_gold = false

func set_loot(_rarity):
	match _rarity:
		"gold":
			is_gold = true
		"mundane":
			potion_reference = preload("res://potions/water.tres")
		"common":
			var roll = randi() % 5
			match roll:
				0:
					potion_reference = preload("res://potions/health_potion.tres")
				1:
					potion_reference = preload("res://potions/fire_breathing.tres")
				2:
					potion_reference = preload("res://potions/water.tres")
				3:
					potion_reference = preload("res://potions/empty_potion.tres")
				4:
					potion_reference = preload("res://potions/slowness.tres")
		"uncommon":
			potion_reference = preload("res://potions/fire_breathing.tres")
		"rare":
			potion_reference = preload("res://potions/empty_potion.tres")
		"epic":
			potion_reference = preload("res://potions/water.tres")
		"legendary":
			potion_reference = preload("res://potions/water.tres")
		"unique": 
			potion_reference = preload("res://potions/water.tres")
	
	if not is_gold:
		$Sprite2D.texture = potion_reference.texture

func _on_area_entered(area):
	print(area.get_name())
	if not is_gold and area.get_name() == "PlayerHurtbox":
		area.owner.inventory.append(potion_reference)
		area.owner.inventory_update.emit(area.owner.inventory)
	elif is_gold:
		area.owner.cash += 5
		area.owner.cash_update.emit(area.owner.cash)
	$"/root/Global".loot_count -= 1
	queue_free()
