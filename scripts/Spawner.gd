extends Marker2D

var enemy_weights = {preload("res://scenes/enemies/mob.tscn") : 1, 
				 preload("res://scenes/enemies/skeleton.tscn") : 2, 
				 preload("res://scenes/enemies/necromancer.tscn") : 10}


func spawn(current_weight):
	pass

func _spawn_enemies(spawn_pos, room_num: int, coord_offset=Vector2.ZERO):
	var monster_weight = clamp(int(room_num / 3), 1, 10) * 3
	var rng = RandomNumberGenerator.new()

	while monster_weight > 0:
		for pos in spawn_pos:
			if monster_weight == 0:
				break

			var spawnable_enemies = []

			for i in range(len(self.enemies)):
				if enemy_weights[enemies[i]] <= monster_weight:
					spawnable_enemies.append(self.enemies[i])

			var offset_pos = Vector2i(pos.x + coord_offset.x, pos.y + coord_offset.y)
			var global_pos = self.floor_map.map_to_local(offset_pos)
			var rand_num = rng.randi_range(0, len(spawnable_enemies) - 1)

			var enemy_instance = spawnable_enemies[rand_num].instantiate()
			
			enemy_instance.position = global_pos
			get_tree().current_scene.get_node("SortingLayer").add_child(enemy_instance)

			monster_weight -= enemy_weights[spawnable_enemies[rand_num]]

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
