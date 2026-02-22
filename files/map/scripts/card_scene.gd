extends Node2D

func _input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int):
	if (event.is_action_pressed("mouseClick")):
		print('card selected')
