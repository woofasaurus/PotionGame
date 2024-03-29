extends StaticBody2D

var legendary_select_scene = preload("res://scenes/legendary_select.tscn")
var popup_scene = preload("res://scenes/hud/popup_text.tscn")
var in_range = false
var open = false
var used = false

var options

func _ready():
	$PopupText.set_text("[R] to open")
	$PopupText.hide()
	options = legendary_select_scene.instantiate()
	get_tree().current_scene.add_child(options)
	options.set_variables()
	options.hide()
	options.connect('free', set_used)

func _input(event):
	if event.is_action_pressed("interact") and in_range and not open:
		$AnimationPlayer.play("open")
		open = true
		options.show()
		$PopupText.hide()

func _on_interact_zone_area_entered(area):
	if area.get_name() == "PlayerHitbox" and not used:
		$PopupText.show()
		in_range = true

func _on_interact_zone_area_exited(area):
	if area.get_name() == "PlayerHitbox":
		$PopupText.hide()
		in_range = false
		if open and not used:
			$AnimationPlayer.play_backwards("open")
			open = false
			if (options != null):
				options.hide()

func set_used():
	used = true
	queue_free() #maybe remove chest
