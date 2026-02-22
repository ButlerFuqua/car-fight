extends Area2D

@export var speed = 400
var angular_speed = PI

@export var Bullet : PackedScene

func bad_guy_shoot():
		$Turret.play("shoot")
		var bullet = Bullet.instantiate()
		var bullet_sprite_sheet = bullet.find_child("image")
		if bullet_sprite_sheet != null:
			bullet_sprite_sheet.animation = "enemy"
		bullet.transform = $BulletSpawnLocation.global_transform
		owner.add_child(bullet)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
