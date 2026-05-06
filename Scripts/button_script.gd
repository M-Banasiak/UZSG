extends Button

var ToolTip: Label
var ToolTipSet: bool:
	get: if tooltip_text == "ExampleTooltip":
		return false
	else: return true
	
func _ready() -> void:
	self.disabled = true
	#Zmieniamy theme buttona, który poza tym jest pusty.
	#To w przyszłości przenieść do głównego theme
	#theme.set_stylebox("panel", "TooltipPanel", UiConstants.SbToolTip)
	#theme.set_font_size("font_size", "Button", 16)
	#theme.set_font_size("font_size", "Label", 8)


func _make_custom_tooltip(for_text:String)->Control:	
	if ToolTipSet == false:
		print(self.name + " tooltip not set")
	ToolTip = UiConstants.BasicToolTip.instantiate()
	if CurrentGameState.IsStartScreen == true:
		ToolTip.text = for_text
	else:
		ToolTip.text = for_text
		
	return ToolTip
