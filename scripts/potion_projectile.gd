extends Area2D
var potion_reference
var direction
var velocity
var spin
var potion_splat_scene = preload("res://scenes/effect_scenes/potion_splat.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	show()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position += velocity*direction.normalized()*delta
	rotation += PI * spin *delta

func set_variables(_potion_reference, _direction, _velocity):
	potion_reference = _potion_reference
	direction = _direction
	velocity = _velocity
	$Sprite2D.texture = potion_reference.texture
	#position += 100*direction.normalized()
	spin = sign(direction.x)*4

func _on_area_entered(area):
	print(area)
	if area.is_in_group("mobs"):
		area.owner.health -= 100
		var potion_splat = potion_splat_scene.instantiate()
		potion_splat.set_color(potion_reference.color)
		get_tree().current_scene.add_child(potion_splat)
		potion_splat.global_position = global_position
		if $"/root/Global".player != null:
			potion_splat.rotation = (get_position() - $"/root/Global".player.get_position()).angle()
	queue_free()

func _on_body_entered(body):
	if body.get_name() == "TileMap":
		#queue_free()
		pass
