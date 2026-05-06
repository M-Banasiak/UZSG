extends Control

var ParentPopUp: PopupPanel:
	get:
		return get_parent()
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass
	
	#var style_box = StyleBoxFlat.new()
	#style_box.set_bg_color(Color(1, 0, 0))
	#style_box.set_border_width_all(2)
	# We assume here that the `theme` property has been assigned a custom Theme beforehand.
	#theme.set_stylebox("panel", "TooltipPanel", style_box)
	#theme.set_color("font_color", "TooltipLabel", Color(0, 1, 1))
	
	
	#print(ParentPopUp.name)
	#print(UiConstants.SbToolTip.bg_color)
	#$".".add_theme_stylebox_override("normal", UiConstants.SbToolTip)
	#ParentPopUp.transparent_bg = true
	#ParentPopUp.transparent = true
	#ParentPopUp.get_viewport().transparent_bg = true
	#ParentPopUp.add_theme_stylebox_override("normal", UiConstants.SbToolTip)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
