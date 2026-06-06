extends Area2D 

@export var bullet_speed: float = 2000
@export var bullet_range: int = 360
var direction: Vector2 = Vector2.RIGHT
var my_shooter: Node2D
var bullet_time: float
var can_hit: bool = true
var target_point: Vector2
var target: Object
var hit_info: Dictionary

@onready var fly_to: RayCast2D = $RayCastFlyTo

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	fly_to.add_exception(my_shooter)
	fly_to.force_raycast_update()
	target_point = fly_to.get_collision_point()
	target = fly_to.get_collider()
	
	bullet_time = bullet_range/bullet_speed
	$Timer.start(bullet_time)
	#print("shooter: " + my_shooter.name)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if target:
		if position == target_point:
			pass
		else:
			position = position.move_toward(target_point, delta * bullet_speed)
	else:
		position += direction * bullet_speed * delta
		
func _on_body_entered(body: Node2D) -> void:
	#kule nie powinny kolidować ze sobą, więc trzeba przenieść kulę na inny collision layer
	if can_hit == false:
		return
	if body == my_shooter:
		return
	
	#var hit_log: String
	#hit_log = str(body.name)
	print(body)
	if hit_info.has(DictConsts.HitData.htTarget):
		print(hit_info[DictConsts.HitData.htTarget]) 
	else:
		print("Pusto")
		
	can_hit = false 
	#visible = false
	#if "hit" in body:
		#body.hit(my_shooter)
	
	#queue_free()
	
func _on_timer_timeout() -> void:
	pass#queue_free()


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
