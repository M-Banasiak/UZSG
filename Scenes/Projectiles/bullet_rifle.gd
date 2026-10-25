extends Area2D 

@export var bullet_speed: float = 2000
@export var bullet_range: float = 640.0 #zasięg (px), po przeleceniu kula znika
@export var max_lifetime: float = 1.0 #zabezpieczenie: kula znika najpóźniej po tym czasie (s)
var traveled: float = 0.0 #przeleciany dystans (px)
var direction: Vector2 = Vector2.RIGHT
var my_shooter: Node2D
var can_hit: bool = true
var target_point: Vector2
var target: Object
var hit_info: Dictionary
var flying_to_target: bool = false #lot do punktu trafienia z raycastu (bez przeskoczenia celu przy dużej prędkości)
var wait_at_target: float = 0.0

#czas oczekiwania w punkcie celu na wykrycie trafienia (kolizje są liczone w kroku fizyki)
const TARGET_HIT_GRACE: float = 0.05

@onready var fly_to: RayCast2D = $RayCastFlyTo

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if is_instance_valid(my_shooter): #null dla kuli z zapisu, której strzelec już nie żył
		fly_to.add_exception(my_shooter)
	find_next_target()
	$Timer.start(max_lifetime)
	#print("shooter: " + my_shooter.name)

#raycast wzdłuż lotu z bieżącej pozycji; bez celu kula leci na wprost (aż poza ekran)
func find_next_target() -> void:
	fly_to.force_raycast_update()
	target = fly_to.get_collider()
	flying_to_target = target != null
	if flying_to_target:
		target_point = fly_to.get_collision_point()
	wait_at_target = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var step_start: Vector2 = position
	move_bullet(delta)
	traveled += position.distance_to(step_start)
	if traveled >= bullet_range:
		queue_free()

func move_bullet(delta: float) -> void:
	if flying_to_target:
		if position != target_point:
			position = position.move_toward(target_point, delta * bullet_speed)
		else:
			#cel mógł się przesunąć - jeśli w punkcie celu nic nie trafimy, pomijamy go
			#i lecimy do kolejnego obiektu na linii lotu
			wait_at_target += delta
			if wait_at_target >= TARGET_HIT_GRACE:
				if is_instance_valid(target):
					fly_to.add_exception(target)
				find_next_target()
	else:
		position += direction * bullet_speed * delta
		
func _on_body_entered(body: Node2D) -> void:
	#kule nie powinny kolidować ze sobą, więc trzeba przenieść kulę na inny collision layer
	if can_hit == false:
		return
	#strzelec mógł zginąć, zanim kula doleciała
	if is_instance_valid(my_shooter) and body == my_shooter:
		return
	
	#var hit_log: String
	#hit_log = str(body.name)
	#print("on_entered: " + str(body))
	#if hit_info.has(DictConsts.HitData.htTarget):
	#	#var tt: String = hit_info[DictConsts.HitData.htTarget]
	#	print("bullet.gd: " + str(hit_info[DictConsts.HitData.htTarget]))
	#else:
	#	print("Pusto")

	can_hit = false
	#skutek trafienia obsługuje trafiony obiekt
	if "hit_alt" in body:
		body.hit_alt(hit_info)
	#visible = false
	#if "hit" in body:
		#body.hit(my_shooter)

	queue_free()
	
func _on_timer_timeout() -> void:
	queue_free() #max_lifetime minął


func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free()
