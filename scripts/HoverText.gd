extends Node2D

func set_text(_title, _text):
	$Title.text = _title
	$Title/Text.text = _text

func _process(delta):
	global_position = get_global_mouse_position()
