extends Marker2D

class_name Spawner

# Can also consider making this a class that spawns mobs when the player is near.
var enemies = [preload("res://scenes/enemies/mob.tscn"),
			   preload("res://scenes/enemies/skeleton.tscn"),
			   preload("res://scenes/enemies/necromancer.tscn")]
var enemy_weights = {preload("res://scenes/enemies/mob.tscn") : 1, 
				 preload("res://scenes/enemies/skeleton.tscn") : 2, 
				 preload("res://scenes/enemies/necromancer.tscn") : 10}

@warning_ignore("native_method_override")
func get_class(): 
	return "Spawner"

func spawn(current_weight, spawn_radius, root_node, global_center, node_path:String=""):
	var rng = RandomNumberGenerator.new()
	var spawnable_enemies = []
	node_path = "./" + node_path
	
	for i in range(len(self.enemies)):
		if enemy_weights[enemies[i]] <= current_weight:
			spawnable_enemies.append(self.enemies[i])

	var rand_num = rng.randi_range(0, len(spawnable_enemies) - 1)

	var enemy_instance = spawnable_enemies[rand_num].instantiate()

	# Uniformly generates a point within a circle 
	var a = rng.randf() * 2 * PI
	var r = spawn_radius * sqrt(rng.randf())
	var rand_offset = Vector2(r * cos(a), r * sin(a))

	var global_pos = global_center + rand_offset
	
	enemy_instance.set_position(global_pos)

	root_node.get_node(node_path).add_child.call_deferred(enemy_instance)
	# root_node.get_node(node_path).add_child(enemy_instance)
	# print("Spawned ", enemy_instance.get_name(), " at ", enemy_instance.get_global_position())
	
	# get_tree().current_scene.get_node("SortingLayer").add_child(enemy_instance)

	return enemy_weights[spawnable_enemies[rand_num]]

# Called when the node enters the scene tree for the first time.
# func _ready():
# 	self.spawn(1, 300)

