extends Area2D


func _input_event(viewport, event, shape_idx):
	if (
		event is InputEventMouseButton 
		and event.button_index == BUTTON_LEFT
		and event.pressed
	):
		print(self.get_parent().brain)
		print(self.get_parent().brain.brain)
