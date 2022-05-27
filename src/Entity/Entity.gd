class_name Entity


extends KinematicBody2D


onready var animation_tree = $AnimationTree
onready var move_vector = animation_tree.get("parameters/Idle/blend_position")
onready var animation_state = animation_tree.get("parameters/playback")
onready var message_board = $MessageBoard
var moving = false
var speed = 100
onready var velocity_vector = animation_tree.get("parameters/Idle/blend_position")

func turns_towards(towards : String) -> void:
	if towards.to_lower() == "left":
		#(1, 0) -> (0, -1) -> (-1, 0) -> (0, 1)
		#(-1, -1) -- (-1, 1) -- (1, 1) -- (1, -1)
		if move_vector.x > 0:
			move_vector += Vector2(-1, -1)
		elif move_vector.x < 0:
			move_vector += Vector2(1, 1)
		elif move_vector.y > 0:
			move_vector += Vector2(1, -1)
		elif move_vector.y < 0:
			move_vector += Vector2(-1, 1)
	elif towards.to_lower() == "right":
		#(1, 0) -> (0, 1) -> (-1, 0) -> (0, -1)
		#(-1, 1) -- (-1, -1) -- (1, -1) -- (1, 1)
		if move_vector.x > 0:
			move_vector += Vector2(-1, 1)
		elif move_vector.x < 0:
			move_vector += Vector2(1, -1)
		elif move_vector.y > 0:
			move_vector += Vector2(-1, -1)
		elif move_vector.y < 0:
			move_vector += Vector2(1, 1)
	animation_tree.set("parameters/Idle/blend_position", move_vector)
	
func move_forward() -> void:
	moving = true


func stop_moving() -> void:
	moving = false


func show_message() -> void:
	message_board.show_message()


func hide_message() -> void:
	message_board.hide_message()


func set_text(message : String) -> void:
	message_board.set_text(message)


func shoot() -> void:
	var bullet = load("res://src/Entity/Bullet.tscn").instance()
	bullet.position = self.position + (move_vector * 40)
	get_tree().current_scene.add_child(bullet)
	bullet.shoot(move_vector)


func _input(event) -> void:
	if event is InputEventKey and event.is_pressed():
		if event.scancode == KEY_ENTER:
			show_message()
		elif event.scancode == KEY_CONTROL:
			hide_message()
		elif event.scancode == KEY_0:
			set_text("ASDFGHJKAKKSAJDJAD")
		elif event.scancode == KEY_1:
			shoot()

func _physics_process(delta : float) -> void:
	if moving:
		animation_tree.set("parameters/Move/BlendSpace2D/blend_position", move_vector)
		animation_state.travel("Move")
		velocity_vector = move_vector * speed
		velocity_vector = move_and_slide(velocity_vector) 
		for i in get_slide_count():
			var collision = get_slide_collision(i)
			if collision.collider.is_in_group("Projectile"):
				collision.collider.hit()
	else:
		animation_state.travel("Idle")
