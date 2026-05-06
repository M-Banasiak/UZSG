extends CanvasLayer

@onready var score_label: Label = $ScoreCounter/VBoxContainer/Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CurrentGameState.connect("score_change", update_score)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func update_score() -> void:
	score_label.text = "Uratowani pracownicy: " + str(CurrentGameState.score).pad_zeros(4)
