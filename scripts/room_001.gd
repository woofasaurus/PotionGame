extends Node2D

@onready var tilemap = $TileMap

# Called when the node enters the scene tree for the first time.
func _ready():
	var my_map_to_local = tilemap.map_to_local(Vector2i(5, 5))
	# Local coordinates don't take into account the trnasformations that are taken.
	my_map_to_local[0] *= tilemap.scale.x 
	my_map_to_local[1] *= tilemap.scale.y

	print(tilemap.get_tileset())
	print(tilemap.get_cell_atlas_coords(0, Vector2(4, 6)))
	print(my_map_to_local)
	print(self.to_global(my_map_to_local)) 
	print("-----")

	print(tilemap.get_used_cells(0))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
