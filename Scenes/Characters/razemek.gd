extends NPCBasicBehavior
class_name Razemek

@export var player_character: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	super(_delta)
	if get_slide_collision_count() > 0:
		var collision = get_last_slide_collision()
		if collision.get_collider():
			var body: Node2D = collision.get_collider()
			if body == curr_target:
				#print("doszedłem do elektrowni, czas umierać")
				if "npc_collided" in body:
					body.npc_collided(CurrentGameState.Factions.fcRazemki)
				queue_free()
	

#func _physics_process(_delta: float) -> void:
	#for i in get_slide_collision_count():
		#var collision = get_slide_collision(i)
		#if collision.get_collider():
			#if collision.get_collider().name=="player":
				#queue_free()

	
func hit(body: Node2D) -> void:
	super(body)
	if "get_faction" in body:
		var fac = body.get_faction()
		match fac:
			CurrentGameState.Factions.fcLibki:
				queue_free()
			_:
				print("Adrian, uważaj!")
	
