extends CanvasLayer

signal free

var hover_text_scene = preload("res://scenes/hud/hover_text.tscn")
var hover_text
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
	player = $"/root/Global".player
	player.aiming = false
	player.get_node("PotionThrowOrigin").hide()
	player.inventory.append(potion1)
	player.inventory_update.emit(player.inventory)
	free.emit()
	queue_free()

func _on_option_2_pressed():
	player = $"/root/Global".player
	player.aiming = false
	player.get_node("PotionThrowOrigin").hide()
	player.inventory.append(potion2)
	player.inventory_update.emit(player.inventory)
	free.emit()
	queue_free()

func _on_option_3_pressed():
	player = $"/root/Global".player
	player.aiming = false
	player.get_node("PotionThrowOrigin").hide()
	player.inventory.append(potion3)
	player.inventory_update.emit(player.inventory)
	free.emit()
	queue_free()



func _on_option_1_mouse_entered():
	hover_text = hover_text_scene.instantiate()
	hover_text.set_text(potion1.name, potion1.description)
	add_child(hover_text)

func _on_option_1_mouse_exited():
	hover_text.queue_free()

func _on_option_2_mouse_entered():
	hover_text = hover_text_scene.instantiate()
	hover_text.set_text(potion2.name, potion2.description)
	add_child(hover_text)

func _on_option_2_mouse_exited():
	hover_text.queue_free()


func _on_option_3_mouse_entered():
	hover_text = hover_text_scene.instantiate()
	hover_text.set_text(potion3.name, potion3.description)
	add_child(hover_text)

func _on_option_3_mouse_exited():
	hover_text.queue_free()
