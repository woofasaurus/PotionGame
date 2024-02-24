extends Area2D

var potion_reference
var is_gold = false
var gold_amount = 0
var rarity
var special

func set_loot(_rarity, _special = "default"): #returns loot of requested type
	if _rarity == "gold":
		is_gold = true;
	else:
		$"/root/Global".loot_count -= 1
		potion_reference = $"/root/Global".get_loot(_rarity, _special)
		$Sprite2D.texture = potion_reference.texture

func _on_area_entered(area):
	if not is_gold and area.get_name() == "PlayerHurtbox":
		area.owner.inventory.append(potion_reference)
		area.owner.inventory_update.emit(area.owner.inventory)
	elif is_gold:
		area.owner.cash += 5
		area.owner.cash_update.emit(area.owner.cash)
	$"/root/Global".loot_count -= 1
	queue_free()
