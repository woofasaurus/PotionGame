extends Node

var player_scene = preload("res://scenes/player/player.tscn")
var mob_scene = preload("res://scenes/enemies/mob.tscn")
var loot_scene = preload("res://loot/loot.tscn")

var goblin_count = 0
var wave_size = 1

func game_over(): #Called when player is dead
	$HUD.show_game_over()

func new_game(): #Called by start button
	$HUD.show_message("Get Ready")
	#Clear existing mobs
	get_tree().call_group("mobs", "queue_free")
	
	#Spawn player
	var player = player_scene.instantiate();
	player.position = Vector2(500,500)
	player.connect('dead', game_over)
	player.connect('health_update', $HUD.update_health)
	player.connect('inventory_update', $HUD.update_inventory)
	player.connect('select_update', $HUD.update_selection)
	player.connect('cash_update', $HUD.update_cash)
	$HUD.update_inventory(player.inventory)
	$HUD.update_selection(player.inventory[player.inventory_index])
	$SortingLayer.add_child(player)
	
	goblin_count = 0
	wave_size = 1
	spawn_goblins(wave_size)

func spawn_goblins(number):
	await get_tree().create_timer(2.0).timeout
	for i in number:
		#Spawn mob
		var mob = mob_scene.instantiate();
		mob.position = Vector2(randi() % 100 + 100, randi() % 700 + 300) #Spawn randomly btwn (100,300) and (1800, 1000)
		mob.connect('dead', decrement_goblin_count)
		$SortingLayer.add_child(mob)
		goblin_count += 1
	$HUD.update_goblin_count(wave_size)
	wave_size += 1

func decrement_goblin_count(_position, _rarity):
	if $"/root/Global".loot_count < $"/root/Global".max_loot:
		var droproll = randi() % 100
		if droproll < 75:
			var loot = loot_scene.instantiate()
			loot.global_position = _position
			$SortingLayer.add_child(loot)
			loot.set_loot(_rarity)
			$"/root/Global".loot_count += 1
		var gold = loot_scene.instantiate()
		gold.set_loot("gold")
		gold.global_position = _position - Vector2(randi()%50 - 25, randi() % 25 + 10)
		$SortingLayer.add_child(gold)
		$"/root/Global".loot_count += 1
		
		var chest = $"/root/Global".chest_reference.instantiate()
		chest.global_position = _position
		$SortingLayer.add_child(chest)
		
	goblin_count -= 1
	if goblin_count == 0:
		spawn_goblins(wave_size)
