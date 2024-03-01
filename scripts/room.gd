extends Node2D

## The tilemap y-coordinate of the first tile of the entrance.
@export var entrance_height: int
## The tilemap y-coordinate of the first tile of the exit.
@export var exit_height: int 
## The the tilemap width of the room from entrance to exit.
@export var room_width: int 

# Can later just get a scene  tree of everything in the room and instantiate them or something, that's be epic #
var torch_positions =  []
var enemey_spawn_positions = []

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass
