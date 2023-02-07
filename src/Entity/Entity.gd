class_name Entity


extends KinematicBody2D


#export (Array, String) var blacklist
export (String) var brain_og
export (bool) var update_node
export (bool) var collision_node
export (bool) var trigger_node
export (bool) var pressed_node
export (bool) var released_node
export (bool) var move_forward_node
export (bool) var rotate_node
export (bool) var timer_node
export (bool) var shoot_node
export (bool) var explode_node
export (bool) var message_node
export (bool) var compare_entity_node
export (bool) var compare_string_node
export (bool) var shoot_trigger_node
export (bool) var activate_node
export (bool) var open_node
export (bool) var close_node


var blacklist : Array


var message_board
var area_2D

var brain_dict := {}
var brain := Brain.new()

var direction := 0.0
var speed := 0.0
var cool_down = 1
var _timer = null
var inmunity_timer = null
var is_shooting = false
var life = 3
var inmunity = false
var inmunity_time = 1
var max_speed = 100
var projectile_owner = null
var initial_postion : Vector2 = Vector2.ZERO
var initial_direction := 0.0
var velocity_vector : Vector2 = Vector2(0.0, 0.0)
var hit_animation_player : AnimationPlayer

func _ready() -> void:
	# Create blacklist
	set_blacklist()
	# Set nodes
	set_nodes()
	# Load default brain
	if brain_og != "":
		var result = JSON.parse(brain_og)
		if result.error == OK:
			brain_dict = result.result
	# Set initial position and direction
	initial_postion = position
	initial_direction = direction
	# Add inmunity timer
	inmunity_timer = Timer.new()
	inmunity_timer.connect("timeout", self, "remove_inmunity")
	inmunity_timer.set_wait_time(inmunity_time)
	inmunity_timer.set_one_shot(true)
	add_child(inmunity_timer)
	# Connection for the ccollisions events
	if area_2D:
		area_2D.connect("body_entered", self, "_on_Area2D_body_entered")
		area_2D.connect("body_entered", self, "_on_Area2D_body_entered_once")
		area_2D.connect("body_exited", self, "_on_Area2D_body_exited")
	# Connection for the global trigger
	Globals.connect("trigger_global", self, "_on_trigger_received")
	# Instance the brain and make all connections
	instance_brain()


func _physics_process(delta : float) -> void:
	if area_2D:
		for body in area_2D.get_overlapping_bodies():
			_on_Area2D_body_entered(body)
	if speed != 0.0:
		var move_vector := Vector2.RIGHT.rotated(deg2rad(direction))
		if self.is_in_group("Projectile"):
			velocity_vector = move_vector * speed
		else:
			velocity_vector += move_vector * speed
			if velocity_vector.distance_to(Vector2.ZERO) > max_speed:
				velocity_vector = velocity_vector.move_toward(move_vector * max_speed, delta * max_speed * 100)
	else:
		velocity_vector = velocity_vector.move_toward(Vector2.ZERO, delta * max_speed * 100)
	velocity_vector = move_and_slide(velocity_vector)


func set_blacklist() -> void:
	if !update_node:
		blacklist.append("UPDATE")
	if !collision_node:
		blacklist.append("COLLISION")
	if !trigger_node:
		blacklist.append("TRIGGER")
	if !pressed_node:
		blacklist.append("PRESSED")
	if !released_node:
		blacklist.append("RELEASED")
	if !move_forward_node:
		blacklist.append("MOVE_FORWARD")
	if !rotate_node:
		blacklist.append("ROTATE")
	if !timer_node:
		blacklist.append("TIMER")
	if !shoot_node:
		blacklist.append("SHOOT")
	if !explode_node:
		blacklist.append("EXPLODE")
	if !message_node:
		blacklist.append("MESSAGE")
	if !compare_entity_node:
		blacklist.append("COMPARE_ENTITY")
	if !compare_string_node:
		blacklist.append("COMPARE_STRING")
	if !shoot_trigger_node:
		blacklist.append("SHOOT_TRIGGER")
	if !activate_node:
		blacklist.append("ACTIVATE")
	if !open_node:
		blacklist.append("OPEN")
	if !close_node:
		blacklist.append("CLOSE")


func set_nodes() -> void:
	message_board = get_node_or_null("MessageBoard")
	area_2D = get_node_or_null("Area2D")
	hit_animation_player = get_node_or_null("HitAnimationPlayer")


func instance_brain() -> void:
	brain.connect("move_forward", self, "move_forward")
	brain.connect("stop_moving", self, "stop_moving")
	brain.connect("turns_towards", self, "turns_towards")
	brain.connect("shoot", self, "shoot")
	brain.connect("show_message", self, "show_message")
	brain.connect("hide_message", self, "hide_message")
	brain.connect("explode", self, "activate_explosion")
	brain.connect("activate", self, "activate")
	brain.connect("open", self, "open")
	brain.connect("close", self, "close")
	brain.brain = brain_dict
	add_child(brain)


func turns_towards(towards : String) -> void:
	if towards.to_lower() == "left":
		direction = fmod(direction - 90.0 + 360.0, 360.0)
	elif towards.to_lower() == "right":
		direction = fmod(direction + 90.0, 360.0)


func move_forward() -> void:
	speed = 10.0


func stop_moving() -> void:
	speed = 0.0


func show_message(text : String) -> void:
	message_board.set_text(text)
	message_board.show_message()


func hide_message() -> void:
	message_board.hide_message()


func shoot() -> void:
	if not is_shooting:
		is_shooting = true
		var bullet = load("res://src/Entity/Bullet.tscn").instance()
		var move_vector := Vector2.RIGHT.rotated(deg2rad(direction))
		bullet.projectile_owner = self.get_instance_id()
		bullet.position = self.position + (move_vector * 40)
		get_tree().current_scene.add_child(bullet)
		bullet.shoot_projectile(move_vector)
		start_shooting()


func open() -> void:
	pass


func close() -> void:
	pass


func start_shooting() -> void:
	#shoot()
	_timer = Timer.new()
	add_child(_timer)
	_timer.connect("timeout", self, "stop_shooting")
	_timer.set_wait_time(cool_down)
	_timer.set_one_shot(true)
	_timer.start()


func stop_shooting() -> void:
	_timer.queue_free()
	_timer = null
	is_shooting = false


func remove_inmunity() -> void:
	inmunity = false
	if hit_animation_player:
		hit_animation_player.play("RESET")


func hurt(knockback_direction : Vector2 = Vector2.ZERO) -> void:
	if not inmunity:
		inmunity = true
		life -= 1
		velocity_vector = knockback_direction * max_speed * 8
		inmunity_timer.start(inmunity_time)
		if hit_animation_player:
			hit_animation_player.play("Hit")
	if life < 1:
		brain.stop()
		queue_free()


func _on_Area2D_body_entered(body) -> void:
	if body.get_instance_id() == self.get_instance_id():
		return
	if self.is_in_group("Projectile"):
		self.hurt()
	
	if self.is_in_group("Enemy") and body.is_in_group("Player"):
		body.hurt(position.direction_to(body.position))
	
#	if self.is_in_group("Teleporter") and body.is_in_group("Player") and is_open:
#		return
#	elif not self.is_in_group("EntityStatic") and body.is_in_group("Player"):
#		body.hurt(position.direction_to(body.position))
#	elif body.is_in_group("Projectile") and body.projectile_owner != self.get_instance_id() and self.is_in_group("Projectile"):
#		body.hurt()
#	elif self.is_in_group("EntityButton"):
#		emit_signal("button_body_entered")
#		$AnimationPlayer.play("ButtonPressed")
#	elif body.is_in_group("Entity") and body.projectile_owner == self.get_instance_id():
#		return
#	elif self.is_in_group("Projectile") and body.is_in_group("Entity") and not body.is_in_group("EntityStatic"):
#		body.hurt(position.direction_to(body.position))
#	elif self.is_in_group("Bomb") and (body.is_in_group("Player") or body.is_in_group("Entity")):
#		body.hurt(position.direction_to(body.position))


func _on_Area2D_body_entered_once(body) -> void:
	if body.get_instance_id() == self.get_instance_id():
		return
	brain.run("COLLISION", body)


func _on_Area2D_body_exited(_body : Node) -> void:
	pass


func activate() -> void:
	pass


func reset_position() -> void:
	position = initial_postion
	direction = initial_direction
	velocity_vector = Vector2.RIGHT.rotated(deg2rad(direction))
	speed = 0.0
	if message_board:
		message_board.reset()
	remove_inmunity()
	life = 3
	brain.queue_free()
	brain = Brain.new()
	instance_brain()


func activate_explosion():
	pass


func _on_trigger_received(tag : String) -> void:
	brain.run("TRIGGER", tag)


func destroy() -> void:
	brain.stop()
	yield(get_tree(), "idle_frame")
	queue_free()
