extends Area2D

@export var speed = 750

func _physics_process(delta: float) -> void:
	position += transform.y * speed * delta * -1

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	# TODO : add damge or kill body
	#queue_free()
	pass
