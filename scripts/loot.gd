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
		potion_reference = $"/root/Global".get_loot(_rarity, _special)
		$Sprite2D.texture = potion_reference.texture

func _on_area_entered(area):
	if area.get_name() == "PlayerHitbox":
		if is_gold:
			area.owner.cash += 5
			area.owner.cash_update.emit(area.owner.cash)
		else:
			area.owner.inventory.append(potion_reference)
			area.owner.inventory_update.emit(area.owner.inventory)
		$"/root/Global".loot_count -= 1
		queue_free()
