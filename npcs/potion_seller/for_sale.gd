extends Area2D

var popup_scene = preload("res://popup_text.tscn")
var potion_reference
var purchaseable = false
var price = -1;

func _ready():
	$PopupText.hide()

func set_variables(_potion_reference, _price):
	price = _price
	potion_reference = _potion_reference
	$Sprite2D.texture = potion_reference.texture
	$PopupText.set_text("[R] to purchase " + _potion_reference.name + "\nFor " + str(price) + "g")

func _on_area_entered(area):
	if area.get_name() == "PlayerHurtbox":
		$PopupText.show()
		purchaseable = true

func _on_area_exited(area):
	if area.get_name() == "PlayerHurtbox":
		$PopupText.hide()
		purchaseable = false

func _input(event):
	if event.is_action_pressed("interact") and purchaseable:
		var player = $"/root/Global".player
		if player.cash >= price:
			player.cash -= price
			player.cash_update.emit(player.cash)
			player.inventory.append(potion_reference)
			player.inventory_update.emit(player.inventory)
