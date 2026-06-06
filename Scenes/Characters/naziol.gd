extends NPCBasicBehavior
class_name Naziol

signal character_spawned(pos: Vector2, type: DictConsts.Factions)

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
			var fac: DictConsts.Factions
			if "get_faction" in body:		
				fac = body.get_faction()		
				if "hit" in body && fac == CurrentGameState.Factions.fcRazemki:				
					var pos: Vector2 = body.global_position
					body.queue_free()
					character_spawned.emit(pos, CurrentGameState.Factions.fcNaziole)
				

func hit(_body: Node2D) -> void:
#func hit(_hit_data: Dictionary) -> void:
	print("naziol hit")
	pass #queue_free()


func _on_notify_npc_area_body_entered(body: Node2D) -> void:
	if ("get_faction" in body) && (curr_target == null):
		var fac: DictConsts.Factions = body.get_faction()
		match fac:
			DictConsts.Factions.fcRazemki:
				curr_target = body
				curr_action = NpcActions.acFollow
