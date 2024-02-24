extends Camera2D

@onready var zoom_label = $ZoomLabel
@onready var mouse_pos = $MousePositionLabel

@export var move_speed = 5000
@export var zoom_speed = 1
@export var zoom_index = 5
@export var zoom_list = [0.05, 0.1, 0.25, 0.5, 0.75, 1.0, 2.0, 3.0]

# negative action, positive action
var motion = Vector2(0, 0)
var base_zoom_pos = Vector2(-951, -513)
var base_label_pos = Vector2(370, -513)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			zoom_index = clamp(zoom_index + 1, 0, len(zoom_list) - 1)
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			zoom_index = clamp(zoom_index - 1, 0, len(zoom_list) - 1)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var mouse_pos_string = "{1}, {2}".format({"1" : int(get_global_mouse_position()[0]), "2" : int(get_global_mouse_position()[0])})
	var space_multiplier = 1 # Goes double speed if you hold space
 
	motion.x = Input.get_axis("move_left", "move_right") 
	motion.y = Input.get_axis("move_up", "move_down")

	if Input.is_action_pressed("ui_accept"):
		space_multiplier += 1

	self.position.x += motion.x * (move_speed * delta) * space_multiplier
	self.position.y += motion.y * (move_speed * delta) * space_multiplier

	self.zoom.x = zoom_list[zoom_index]
	self.zoom.y = zoom_list[zoom_index]
	
	zoom_label.text = "Zoom: {zoom_level}x".format({"zoom_level" : zoom_list[zoom_index]})
	mouse_pos.text = "Mouse pos: {mouse_pos}".format({"mouse_pos" : mouse_pos_string})

	zoom_label.scale.x = 1 / zoom_list[zoom_index]
	zoom_label.scale.y = 1 / zoom_list[zoom_index]
	mouse_pos.scale.x = 1 / zoom_list[zoom_index]
	mouse_pos.scale.y = 1 / zoom_list[zoom_index]
	zoom_label.position.x = base_zoom_pos[0] / zoom_list[zoom_index]
	zoom_label.position.y = base_zoom_pos[1] / zoom_list[zoom_index]
	mouse_pos.position.x = base_label_pos[0] / zoom_list[zoom_index]
	mouse_pos.position.y = base_label_pos[1] / zoom_list[zoom_index]
