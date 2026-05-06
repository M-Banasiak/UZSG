extends StaticBody2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func npc_collided(faction: CurrentGameState.Factions) -> void:
	if faction == CurrentGameState.Factions.fcRazemki:
		CurrentGameState.score += 1
		
