extends CanvasLayer

signal start_game


func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()

func _process(_delta):
	if $"/root/Global".player != null:
		var thirst_level = ($"/root/Global".player.thirst/$"/root/Global".player.max_thirst)
		$ScreenThirst.set_modulate(Color(1, 1, 0.5, (1 - thirst_level)*0.5))

func show_game_over():
	show_message("Game Over!")
	await $MessageTimer.timeout
	
	$Message.text = "AGANE AGANE!"
	$Message.show()
	
	await get_tree().create_timer(0.5).timeout
	$StartButton.show()

func update_health(health):
	$ScoreLabel.text = str(health)

func update_goblin_count(goblins):
	$GoblinCount.text = str(goblins)

func update_cash(cash):
	$Cash.text = str(cash)

func update_inventory(inventory, selection): #called by inventory_update signal emitted by player, connected in main
	if (selection >= 0 and selection < inventory.size()):
		$InventorySelection.text = inventory[selection].name
		$InventorySelection/InventoryWheel.update(inventory, selection)
	else:
		$InventorySelection.text = "empty"
	
	$Inventory.text = ""
	for i in inventory:
		$Inventory.text += i.name + ", "

func _on_start_button_pressed():
	$StartButton.hide()
	update_health(400)
	start_game.emit()

func _on_message_timer_timeout():
	$Message.hide()
