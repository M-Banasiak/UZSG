extends CharacterBody2D
class_name NPCBasicBehavior

enum NpcActions {acFollow, acGoto, acPatrol}

@export var faction:  DictConsts.Factions
@export var curr_target: Node2D
var curr_target_pos: Vector2
var curr_action: NpcActions
var speed: int
@export var patrol_speed: int
@export var attack_speed: int

var direction: Vector2

#var player_goal: NPCBasicBehavior  #musi być zdefiniowana klasa. Potem zrobimy klasę dla elektrowni, która zwróci position

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	curr_target_pos = global_position
	if curr_target != null:
		curr_action = NpcActions.acFollow
	else:
		curr_action = NpcActions.acPatrol

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if curr_target != null:  #is_instance_valid
		curr_action = NpcActions.acFollow
	else:
		curr_action = NpcActions.acPatrol
		
	#tu zrobić żeby nie wywoływać na każdym process
	#może action_initialize() i potem signal action_completed
	match curr_action:
		NpcActions.acFollow:
			speed = attack_speed
			follow_object()
		NpcActions.acPatrol:
			speed = patrol_speed
			patrol_random()

func follow_object():
	direction = Vector2(curr_target.global_position - global_position).normalized()
	velocity = direction * speed
	if speed > 0:
		move_and_slide()


func patrol_random() -> void:
	#sprawdzamy czy poza ekranem
	if (((global_position.x < 0) || (global_position.x > 640)) || 
	((global_position.y < 0) || (global_position.y > 360))):
		var target_pos: Vector2 = Vector2(randf_range(0, 640),
		randf_range(0, 360))
		curr_target_pos = target_pos
		curr_action = NpcActions.acPatrol
		#$ActionTimer.stop()
		$ActionTimer.start(3)
	else :
		#if ((global_position.distance_to(curr_target_pos) > 64) || 
		#jeszcze trzeba coś zrobić jak zbyt długo nie może dojść
		if (global_position.distance_to(curr_target_pos) < 9):
			var target_pos: Vector2 = Vector2(randf_range(global_position.x - 64, global_position.x + 64),
			randf_range(global_position.y - 64, global_position.y + 64))
			curr_target_pos = target_pos
			curr_action = NpcActions.acPatrol
			#$ActionTimer.stop()
			$ActionTimer.start(3)
		#else:
	direction = Vector2(curr_target_pos - global_position).normalized()
	velocity = direction * speed
	if speed > 0: 
		move_and_slide()
		

func hit(_body: Node2D) -> void:
	pass#print("Basic Dostałem od: " + body.name)
	
func hit_alt(_hit_data: Dictionary) -> void:
	pass #print(str(self.name) + " hit by: " + str(DictConsts.faction_dict[hit_data[DictConsts.HitData.htFaction]]))

func get_faction() -> DictConsts.Factions:
	return faction
	
func get_type() -> DictConsts.ObjectType:
	return DictConsts.ObjectType.otNpc

#jeśli akcja trwa za długo
func _on_action_timer_timeout() -> void:
	#$ActionTimer.stop()
	if curr_action == NpcActions.acPatrol:
		curr_target_pos = global_position
		
