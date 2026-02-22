extends CharacterBody2D

signal shoot

@export var Bullet : PackedScene

@export var sterring_angle = 15 
@export var engine_power = 900 # force for acceleration
@export var friction = -55 # slow down car
@export var drag = -0.06 # air drag slow down car
@export var braking = -450
@export var max_speed_reverse = 250
@export var slip_speed = 400 # traction decrease for drifiting
@export var traction_fast = 2.5 # traction when car is moving fast (affects control)
@export var traction_slow = 10 # traction when car is moving slow (affects slow)

var wheel_base = 65 #distance between front and back axles
var acceleration = Vector2.ZERO
var steer_direction

# Called when the node enters the scene tree for the first time.
var screen_size
func _ready() -> void:
	screen_size = get_viewport_rect().size
	print(screen_size)

func player_shoot():
		$Turret.play("shoot")
		shoot.emit()
		var bullet = Bullet.instantiate()
		var bullet_sprite_sheet = bullet.find_child("image")
		if bullet_sprite_sheet != null:
			bullet_sprite_sheet.animation = "player"
		bullet.transform = $BulletSpawnLocation.global_transform
		bullet.scale = bullet.scale / 10
		owner.add_child(bullet)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	acceleration = Vector2.ZERO
	get_input()
	apply_friction(delta)
	calculate_steering(delta)
	velocity += acceleration * delta
	
	move_and_slide()

	if(Input.is_action_just_pressed("shoot")):
		player_shoot()
		
	#	Rest position
	if Input.is_action_pressed("ui_text_backspace"):
		position = Vector2(100,100)
		rotation = -90

func get_input():
	var turn = Input.get_axis("ui_left", "ui_right")
	steer_direction = turn * deg_to_rad(sterring_angle)
	
	# if accelerate is pressed, apply engine power to forward
	if Input.is_action_pressed("ui_up"):
		acceleration = transform.x * engine_power
	
	# if brake is pressed
	if Input.is_action_pressed("ui_down"):
		acceleration = transform.x * braking

func calculate_steering(delta):
	# calculate positions of the rear and front wheel
	var rear_wheel = position - transform.x * wheel_base / 2.0
	var front_wheel = position + transform.x * wheel_base / 2.0
	# advance the whee's positions based on the current velocity, applying rotation to front wheel
	rear_wheel += velocity * delta
	front_wheel += velocity.rotated(steer_direction) * delta
	# calculate the new heading based on the wheels; positions
	var new_heading = rear_wheel.direction_to(front_wheel)
	
	# choose the traction model based on the current speed
	var traction = traction_slow
	if velocity.length() > slip_speed:
		traction = traction_fast
		
	#Dot product represents how aligned the new heading is with current velocity direciton
	var d = new_heading.dot(velocity.normalized())
	
	#if not braking, adjust car velocity smoothly toward new heading
	if d> 0:
		velocity = lerp(velocity, new_heading * velocity.length(), traction * delta)
	
	#if braking, reverse the direction and limit the speed
	if d < 0:
		velocity = -new_heading * min(velocity.length(), max_speed_reverse)
	
	# updat ethe car's rotation to face the direction of the new heading
	rotation = new_heading.angle()

# apply friction, making it slide to a halt
func apply_friction(delta):
	# if no input and speed is low, stop to prevent sliding
	if acceleration == Vector2.ZERO and velocity.length() < 50:
		velocity = Vector2.ZERO
	# calculate friction force and air drag based on current velocity, and apply it
	var friction_force = velocity * friction * delta
	var drag_force = velocity * velocity.length() * drag * delta
	# Add the forces to the acceleration
	acceleration += drag_force + friction_force
