extends CanvasLayer

@onready var score_label: Label = $ScoreCounter/VBoxContainer/Label
@onready var fire_mode_label: Label = $FireModeLabel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	CurrentGameState.connect("score_change", update_score)
	CurrentGameState.connect("fire_mode_change", update_fire_mode)
	update_score()
	update_fire_mode() #player ustawia tryb w _ready zanim UI się podłączy

#teksty składane w kodzie trzeba odświeżyć po zmianie języka
func _notification(what: int) -> void:
	if what == NOTIFICATION_TRANSLATION_CHANGED and is_node_ready():
		update_score()
		update_fire_mode()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func update_score() -> void:
	score_label.text = tr("HUD_SCORE") + ": " + str(CurrentGameState.score).pad_zeros(4)

func update_fire_mode() -> void:
	fire_mode_label.text = tr("HUD_FIRE_MODE") + ": " + tr(CurrentGameState.fire_mode_name)
