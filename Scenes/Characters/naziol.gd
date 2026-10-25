extends NPCBasicBehavior
class_name Naziol

signal character_spawned(pos: Vector2, type: DictConsts.Factions)
signal gun_fired(bullet_data: Dictionary) #level tworzy kulę, tak jak dla gracza

#losowy odstęp między strzałami do gracza (s)
@export var shoot_delay_min: float = 3.0
@export var shoot_delay_max: float = 7.0

@onready var gun: Node2D = $Weapons/AdiGun
var is_aiming: bool = false #broń obraca się w stronę gracza, strzał po wycelowaniu

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	restart_shoot_timer()

func restart_shoot_timer() -> void:
	$ShootTimer.start(randf_range(shoot_delay_min, shoot_delay_max))

func _on_shoot_timer_timeout() -> void:
	is_aiming = true

#obraca broń w stronę gracza (śledzi go, jeśli się porusza) i strzela po wycelowaniu
#na razie bez efektu dla gracza
func aim_and_shoot(delta: float) -> void:
	if gun.turn_towards(CurrentGameState.player_pos, delta):
		is_aiming = false
		gun_fired.emit(gun.fire_single())
		restart_shoot_timer()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	if is_aiming:
		aim_and_shoot(delta)
	if get_slide_collision_count() > 0:
		var collision = get_last_slide_collision()
		if collision.get_collider():
			var body: Node2D = collision.get_collider()
			var fac: DictConsts.Factions
			if "get_faction" in body:		
				fac = body.get_faction()		
				if "hit" in body && fac == DictConsts.Factions.fcRazemki:				
					var pos: Vector2 = body.global_position
					body.queue_free()
					character_spawned.emit(pos, DictConsts.Factions.fcNaziole)
				

func hit(_body: Node2D) -> void:
#func hit(_hit_data: Dictionary) -> void:
	#print("naziol hit")
	pass #queue_free()

#trafienie kulą - na razie bez punktów życia i pancerza, jedno trafienie usuwa
func hit_alt(_hit_data: Dictionary) -> void:
	queue_free()


func _on_notify_npc_area_body_entered(body: Node2D) -> void:
	if ("get_faction" in body) && (curr_target == null):
		var fac: DictConsts.Factions = body.get_faction()
		match fac:
			DictConsts.Factions.fcRazemki:
				curr_target = body
				curr_action = NpcActions.acFollow
