extends Node

#podstawowe komponenty
var BasicToolTip: PackedScene = preload("res://Scenes/UI/tool_tip_label.tscn")  #Label

var BigButtonFontSize: int = 16

#StyleBox dla panelu tooltipa (PopupPanel). Ten panel jest tworzony dynamicznie i styl trzeba 
#przypisywać w momencie utworzenia komponentu nadrzędnego
var SbToolTip = StyleBoxFlat.new()
var ToolTipBgColor: Color = Color8(255,0,0,230)  #Color8(33,33,33,230)

func _ready() -> void:
	print("Setting graphic styles")
	SbToolTip.set_bg_color(ToolTipBgColor)
	SbToolTip.set_border_width_all(0)
	SbToolTip.set_corner_radius_all(2)
	SbToolTip.corner_detail = 16
	#SbToolTip.anti_aliasing = true
	#SbToolTip.anti_aliasing_size = 2
	#SbToolTip.bg_color = ToolTipBgColor
	
