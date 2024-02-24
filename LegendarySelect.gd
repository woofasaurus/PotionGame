extends CanvasLayer

signal free

var player
var potion1
var potion2
var potion3

func set_variables():
	assert($"/root/Global".player != null, "You fucking dumbass, no player is initialized")
	player = $"/root/Global".player
	potion1 =  $"/root/Global".get_loot("legendary")
	potion2 =  $"/root/Global".get_loot("legendary")
	potion3 =  $"/root/Global".get_loot("legendary")
	$Option1.icon = potion1.texture
	$Option2.icon = potion2.texture
	$Option3.icon = potion3.texture

func _on_option_1_pressed():
	player.inventory.append(potion1)
	player.inventory_update.emit(player.inventory)
	free.emit()
	queue_free()

func _on_option_2_pressed():
	player.inventory.append(potion2)
	player.inventory_update.emit(player.inventory)
	free.emit()
	queue_free()

func _on_option_3_pressed():
	player.inventory.append(potion3)
	player.inventory_update.emit(player.inventory)
	free.emit()
	queue_free()
