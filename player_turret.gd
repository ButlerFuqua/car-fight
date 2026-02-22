extends Area2D

@export var speed = 400
var angular_speed = PI

@export var Bullet : PackedScene

signal shoot

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func player_shoot():
		$Turret.play("shoot")
		shoot.emit()
		var bullet = Bullet.instantiate()
		bullet.transform = $BulletSpawnLocation.global_transform
		#if owner != null:
		owner.add_child(bullet)
		#else:
			#print("ERROR, owner is null")
		
		#$Turret.play("shoot")
		#shoot.emit()
		#var bullet = Bullet.instantiate()
		#bullet.transform = $BulletSpawnLocation.global_transform
		#owner.add_child(bullet)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
#	MOVE
	var direction = 0
	if Input.is_action_pressed("ui_left"):
		direction = -1
	if Input.is_action_pressed("ui_right"):
		direction = 1
		
	rotation += angular_speed * direction * delta
	
	var velocity = Vector2.ZERO
	if Input.is_action_pressed("ui_up"):
		velocity = Vector2.UP.rotated(rotation) * speed
	if Input.is_action_pressed("ui_down"):
		velocity = Vector2.DOWN.rotated(rotation) * speed
		
	position += velocity * delta
#	END MOVE

#Shoot
	if Input.is_action_pressed("shoot") && !$Turret.is_playing():
		player_shoot()
		
#	Rest position
	if Input.is_action_pressed("ui_text_backspace"):
		position = Vector2.ZERO
		rotation = 0
	
	
