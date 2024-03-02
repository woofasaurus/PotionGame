extends Label

var inventory_slot_scene = preload("res://scenes/hud/inventory_slot.tscn")
@export var radius = 200
@export var selected_scale_multiplier = 2
@export var selected_x_range = 145
@export var packing = 10
@export var scroll_speed = 0.1
@export var threshold = 0.01
var wheel_rotation = 0.0
var padding = 2*PI/packing
var inventory_array = [] #stores inventory objects
var position_array = [] #stores vector values, associated with position to display
var real_inventory = [preload("res://potions/fire_breathing.tres"), 
					  preload("res://potions/water.tres"), 
					  preload("res://potions/water.tres")]
var stopped = true
var select_previous = 0
var select_position = 0
var select_inventory = 0
var num_rendered = 4

func _ready():
	full_update(real_inventory, 0)

func full_update(_inventory, _selection):
	real_inventory = _inventory
	inventory_array = []
	for i in _inventory:
		var child = inventory_slot_scene.instantiate()
		add_child(child)
		inventory_array.append(child)
		child.get_node("Sprite2D").texture = i.texture
	select_inventory = _selection
	select_position = 0
	
	update_packing(_inventory.size())

func update_packing(_size):
	radius = 100*_size
	position.y = 1600+radius
	$SelectionName.position.y = -300-radius
	packing = min(_size, 20)
	padding = min(2*PI/packing, 2*PI)
	num_rendered = max(1, min(_size/2, 8))
	position_array = []
	for i in range(packing):
		position_array.append(i)
	#print("PADDING: " + str(padding) + " PACKING: " + str(packing) + " WHEEL: " +str(wheel_rotation))

func is_empty():
	return real_inventory.is_empty()

func get_selected():
	if real_inventory.size() > 0:
		return real_inventory[select_inventory%real_inventory.size()]
	return null

func pop_selected():
	if real_inventory.size() > 0:
		inventory_array.pop_at(select_inventory%real_inventory.size()).queue_free()
		
		update_packing(real_inventory.size() - 1)
		
		#wheel_rotation -= 0.6*padding
		return real_inventory.pop_at(select_inventory%real_inventory.size())
	return null

func pop_drink():
	if real_inventory.size() > 0:
		var _potion_reference = real_inventory[select_inventory%real_inventory.size()]
		real_inventory[select_inventory%real_inventory.size()] = preload("res://potions/empty_potion.tres")
		inventory_array[select_inventory%real_inventory.size()].get_node("Sprite2D").texture = real_inventory[select_inventory%real_inventory.size()].texture
		return _potion_reference
	return null

func append(_potion_reference):
	real_inventory.append(_potion_reference)
	
	var child = inventory_slot_scene.instantiate()
	add_child(child)
	inventory_array.append(child)
	child.get_node("Sprite2D").texture = _potion_reference.texture
	
	update_packing(real_inventory.size())
	wheel_rotation -= 0.3*padding

func _process(delta):
	if (real_inventory.size() > 0):
		$SelectionName.text = real_inventory[select_inventory%real_inventory.size()].name
	else:
		$SelectionName.text = "-"
	
	if wheel_rotation > 2*PI:
		wheel_rotation -= 2*PI
	if wheel_rotation < 0:
		wheel_rotation += 2*PI
	
	if stopped:
		var remainder = fmod(wheel_rotation, padding)
		var target = 0
		if remainder < padding/2:
			target = wheel_rotation - fmod(wheel_rotation, padding)
		else:
			target = wheel_rotation + padding - fmod(wheel_rotation, padding)
		wheel_rotation += (target - wheel_rotation)*delta*10
	
	if real_inventory.size() > 0:
		update_slot_positions()

func _input(event): #handles scrolling through inventory
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			wheel_rotation += padding
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			wheel_rotation -= padding
	if event is InputEventPanGesture:
		stopped = false
		if (abs(event.delta.y) > threshold):
			wheel_rotation +=  scroll_speed*event.delta.y
		else:
			stopped = true
	else: stopped = true
	if real_inventory.size() > 0:
		update_slot_positions()

func update_slot_positions():
	
	for i in position_array.size():
		position_array[i] = Vector2( sin(wheel_rotation + (i)*padding) * radius, -cos(wheel_rotation + (i)*padding) * radius) #updates positions of position array
		
		if abs(position_array[i].x) < selected_x_range and position_array[i].y < -0.8*radius: #if the position value is top, set it as the selection
			select_position = i
			if select_position != select_previous:
				select_inventory += select_position-select_previous
				select_previous = select_position
				print("POSITIONING " + str(select_position) + " INVEN: " + str(select_inventory) + " PACKING: " + str(packing))
	
	for i in range(inventory_array.size()):
		inventory_array[i%inventory_array.size()].position = Vector2(0,radius*2)
	
	for i in range(select_inventory-num_rendered, select_inventory+num_rendered+1):
		inventory_array[i %inventory_array.size()].position = position_array[(i)%position_array.size()] #set specific positions
		if int(i)%inventory_array.size() == int(select_inventory)%inventory_array.size(): #if the selection
			inventory_array[i%inventory_array.size()].scale = Vector2(selected_scale_multiplier,selected_scale_multiplier)
		else:
			inventory_array[i%inventory_array.size()].scale = Vector2(1,1) #resets if more are rendered than are in array
