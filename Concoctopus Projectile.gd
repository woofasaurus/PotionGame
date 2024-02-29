extends Area2D
var direction
var velocity
var spin

# Called when the node enters the scene tree for the first time.
func _ready():
	show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += velocity*direction.normalized()*delta
	rotation += PI * spin *delta

func set_variables(_direction, _velocity):
	direction = _direction
	velocity = _velocity
	position += scale*200*direction.normalized()
	spin = sign(direction.x)*4

func _on_area_entered(area):
	if area.get_name() == "PlayerHitbox":
		area.owner.health -= 1
	queue_free()

func _on_body_entered(body):
	if body.get_name() == "TileMap":
		queue_free()
