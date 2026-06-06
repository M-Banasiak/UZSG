extends Marker2D

enum Sides {sLeft, sRight, sBottom, sTop}
enum RespawnTimerMode {rtInc, rtDec, rtNone}

@export var available_factions: Array[DictConsts.Factions]
@export var base_delay: float = 5
@export var auto_spawn: bool = true
@export var timer_mode: RespawnTimerMode

var seconds_delay: float
#var razem_guy: PackedScene = preload("res://Scenes/Characters/razemek.tscn")

signal character_spawned(pos: Vector2, type: DictConsts.Factions)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	seconds_delay = base_delay
	if auto_spawn == true:
		$RespawnTimer.start(seconds_delay)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
		
func _on_respawn_timer_timeout() -> void:
	spawn_screenedge()
	
	if auto_spawn == true:
		if timer_mode != RespawnTimerMode.rtNone:
			var sc: int = CurrentGameState.score
			@warning_ignore("integer_division")
			var delta: float = floor(sc/10)
			delta = delta/10
			var new_delay: float 
			if timer_mode == RespawnTimerMode.rtInc:
				new_delay = base_delay + delta
			else:
				new_delay = base_delay - delta 
				if new_delay <= 0:
					new_delay = base_delay
			
			if new_delay != seconds_delay:
				seconds_delay = new_delay			
				$RespawnTimer.stop()
				$RespawnTimer.start(seconds_delay)
	else :
		$RespawnTimer.stop()
	
func spawn_screenedge() -> void:
	#var new_razemguy: Node2D = razem_guy.instantiate()
	@warning_ignore("narrowing_conversion")
	var w: int = get_viewport().get_visible_rect().size.x
	@warning_ignore("narrowing_conversion")
	var h: int = get_viewport().get_visible_rect().size.y
	
	var side: Sides = randi() % Sides.size() as Sides
	var spawn_pos: Vector2
	
	if side == Sides.sLeft:
		spawn_pos = Vector2(-1, randi_range(0, h))
	elif  side == Sides.sRight:
		spawn_pos = Vector2(w + 1, randi_range(0, h))
	elif  side == Sides.sTop:
		spawn_pos = Vector2(randi_range(0, w), -1)
	elif  side == Sides.sRight:
		spawn_pos = Vector2(randi_range(0, w), h + 1)
		
	var faction: DictConsts.Factions = available_factions[randi() % available_factions.size()]
	character_spawned.emit(spawn_pos, faction)
#to ma być na level a spawner ma emitować signal przekazując global position i node2d do pokazania
#func _ready() -> void:
	#for container in get_tree().get_nodes_in_group("Container"):
		#container.connect("open", _on_container_opened)
	#for scout in get_tree().get_nodes_in_group("Scouts"):
		#scout.connect("laser", _on_scout_laser)
	 #
#func _on_container_opened(pos, directon):
	
