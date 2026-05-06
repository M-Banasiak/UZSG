extends NPCBasicBehavior
class_name Libek

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	super(_delta)
	if get_slide_collision_count() > 0:
		var collision = get_last_slide_collision()
		if collision.get_collider():
			var body: Node2D = collision.get_collider()
			var fac: CurrentGameState.Factions
			if "get_faction" in body:		
				fac = body.get_faction()		
			if "hit" in body && fac == CurrentGameState.Factions.fcRazemki:
				body.hit(self)

	
func hit(_body: Node2D) -> void:
	queue_free()


func _on_notify_npc_area_body_entered(body: Node2D) -> void:
	
	if ("get_faction" in body) && (curr_target == null):
		var fac: CurrentGameState.Factions = body.get_faction()
		match fac:
			CurrentGameState.Factions.fcRazemki:
				curr_target = body
				curr_action = NpcActions.acFollow
