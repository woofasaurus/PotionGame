extends Node

var player_scene = preload("res://scenes/player/player.tscn")
var mob_scene = preload("res://scenes/enemies/mob.tscn")
var skeleton_scene = preload("res://scenes/enemies/skeleton.tscn")
var necromancer_scene = preload("res://scenes/enemies/necromancer.tscn")
var concoctopus_scene = preload("res://scenes/enemies/concoctopus.tscn")
var mimic_scene = preload("res://scenes/enemies/mimic.tscn")
var loot_scene = preload("res://scenes/loot.tscn")

var player
var goblin_count = 0
var wave_size = 1

func game_over(): #Called when player is dead
	$HUD.show_game_over()
	get_tree().call_group("mobs", "queue_free")

func new_game(): #Called by start button
	$HUD.show_message("Get Ready")
	#Clear existing mobs
	#get_tree().call_group("mobs", "queue_free") WE ARE NOT ALLOWED TO DELETE THIS LINE. THIS LINE HAS TO SIT HERE AND THINK ABOUT WHAT ITS DONE. FUCK THIS LINE.
	
	var concoctopus = concoctopus_scene.instantiate();
	concoctopus.position = Vector2(20000,500)
	$SortingLayer.add_child(concoctopus)
	#Spawn player
	player = player_scene.instantiate();
	player.position = Vector2(500,500)
	player.connect('dead', game_over)
	player.connect('health_update', $HUD.update_health)
	player.connect('inventory_update', $HUD.update_inventory)
	player.connect('cash_update', $HUD.update_cash)
	$SortingLayer.add_child(player)
	
	goblin_count = 0
	wave_size = 1

func spawn_goblins(number):
	await get_tree().create_timer(2.0).timeout
	for i in number:
		var roll = randi() % 100
		var mob = mob_scene.instantiate();
		if roll < 50:
			print ("SKELER")
			mob = skeleton_scene.instantiate();
			if roll < 10:
				print ("NECRO")
				mob = necromancer_scene.instantiate()
		mob.position = player.global_position + Vector2(randi() % 1000 -500, randi() % 1000 -500) #Spawn randomly btwn (100,300) and (1800, 1000)
		mob.connect('dead', decrement_goblin_count)
		$SortingLayer.add_child(mob)
		goblin_count += 1
	$HUD.update_goblin_count(wave_size)
	wave_size += 1

func decrement_goblin_count(_position, _rarity):
	goblin_count -= 1

func _on_goblin_timer_timeout():
	#spawn_goblins(wave_size)
	pass
