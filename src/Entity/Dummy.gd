tool


extends Entity


onready var animation_player := $AnimationPlayer as AnimationPlayer


func _process(_delta : float) -> void:
	if speed != 0.0:
		if direction == 0.0 || direction == 360.0:
			animation_player.play("MoveRight")
		elif direction == 90.0:
			animation_player.play("MoveDown")
		elif direction == 180.0:
			animation_player.play("MoveLeft")
		elif direction == 270.0:
			animation_player.play("MoveUp")
	else:
		if direction == 0.0 || direction == 360.0:
			animation_player.play("IdleRight")
		elif direction == 90.0:
			animation_player.play("IdleDown")
		elif direction == 180.0:
			animation_player.play("IdleLeft")
		elif direction == 270.0:
			animation_player.play("IdleUp")
