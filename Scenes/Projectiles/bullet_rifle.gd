extends Area2D 

#
@export var bullet_speed: float = 1000
@export var bullet_range: int = 300
var direction: Vector2 = Vector2.RIGHT
var my_shooter: Node2D
var bullet_time: float
var can_hit: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	bullet_time = bullet_range/bullet_speed
	$Timer.start(bullet_time)
	#print("shooter: " + my_shooter.name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position += direction * bullet_speed * delta

func _on_body_entered(body: Node2D) -> void:
	#kule nie powinny kolidować ze sobą, więc trzeba przenieść kulę na inny collision layer
	if can_hit == false:
		return
	if body == my_shooter:
		return
		
	can_hit = false 
	visible = false
	if "hit" in body:
		body.hit(my_shooter)
	
	queue_free()
	
func _on_timer_timeout() -> void:
	queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
