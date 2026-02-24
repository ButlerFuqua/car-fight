extends CharacterBody2D

signal shoot

@export var Bullet : PackedScene

@export var sterring_angle = 15 
@export var engine_power = 900
@export var friction = -55 
@export var drag = -0.06 
@export var braking = -700
@export var max_speed_reverse = 750
@export var slip_speed = 400 
@export var traction_fast = 2.5 
@export var traction_slow = 10 

# AI Specific Settings
@export var stopping_distance = 200 # Distance to stop and just shoot
@export var shoot_range = 500

var wheel_base = 65 
var acceleration = Vector2.ZERO
var steer_direction = 0

func _ready() -> void:
	pass

func enemy_shoot():
	# Simple cooldown check so it doesn't shoot every single frame
	if not $Turret.is_playing():
		$Turret.play("shoot")
		shoot.emit()
		var bullet = Bullet.instantiate()
		var bullet_sprite_sheet = bullet.find_child("image")
		if bullet_sprite_sheet != null:
			bullet_sprite_sheet.animation = "enemy"
		bullet.transform = $BulletSpawnLocation.global_transform
		bullet.scale = bullet.scale #/ 10
		get_parent().add_child(bullet)

func _physics_process(delta: float) -> void:
	acceleration = Vector2.ZERO
	
	# 1. Check if player exists in our Global singleton
	if Global.player:
		ai_logic()
		
		# 2. Shooting logic
		var dist = global_position.distance_to(Global.player.global_position)
		if dist < shoot_range:
			enemy_shoot()
	else:
		# If player is dead/missing, just slow down
		steer_direction = 0
	
	apply_friction(delta)
	calculate_steering(delta)
	velocity += acceleration * delta
	move_and_slide()

func ai_logic():
	var target_pos = Global.player.global_position
	var distance = global_position.distance_to(target_pos)
	
	# --- STEERING LOGIC ---
	# Calculate the vector to the player
	var dir_to_player = global_position.direction_to(target_pos)
	
	# Determine if player is to the left or right using the Dot Product
	# transform.y is the "right" side of the car in Godot 2D
	var side_dot = transform.y.dot(dir_to_player)
	
	# Set steer_direction based on side
	if side_dot > 0.1:
		steer_direction = deg_to_rad(sterring_angle) # Turn Right
	elif side_dot < -0.1:
		steer_direction = -deg_to_rad(sterring_angle) # Turn Left
	else:
		steer_direction = 0 # Go Straight
		
	# --- ACCELERATION LOGIC ---
	if distance > stopping_distance:
		acceleration = transform.x * engine_power
	else:
		# Slow down if too close
		acceleration = transform.x * braking

func calculate_steering(delta):
	var rear_wheel = position - transform.x * wheel_base / 2.0
	var front_wheel = position + transform.x * wheel_base / 2.0
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta
	var new_heading = rear_wheel.direction_to(front_wheel)
	
	var traction = traction_slow
	if velocity.length() > slip_speed:
		traction = traction_fast
		
	var d = new_heading.dot(velocity.normalized())
	
	if d > 0:
		velocity = lerp(velocity, new_heading * velocity.length(), traction * delta)
	if d < 0:
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)
	
	rotation = new_heading.angle()

func apply_friction(delta):
	if acceleration == Vector2.ZERO and velocity.length() < 50:
		velocity = Vector2.ZERO
	var friction_force = velocity * friction * delta
	var drag_force = velocity * velocity.length() * drag * delta
	acceleration += drag_force + friction_force
