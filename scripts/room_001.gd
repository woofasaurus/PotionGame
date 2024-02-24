extends Node2D

@onready var tilemap = $TileMap

# Called when the node enters the scene tree for the first time.
func _ready():
	print(tilemap.get_tileset())
	print(tilemap.get_cell_atlas_coords(0, Vector2(4, 6)))


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
