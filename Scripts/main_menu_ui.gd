extends CanvasLayer

class_name  MainMenu

var level_scene: PackedScene = preload("res://Scenes/Levels/level.tscn")
var title_scene: PackedScene = preload("res://Scenes/title_scene.tscn")

@export var BackGroundVisible: bool

var IsActiveSave: bool = false
var quitting: bool = false

var ActiveButoon: Button:
	get: if IsActiveSave == false:
		return $MainMenu/MenuItems/BtnNew
	else:
		return $MainMenu/MenuItems/BtnContinue

signal  mainmenu_game_quit()

signal  mainmenu_new_game()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var MItems: VBoxContainer = $MainMenu/MenuItems
	#Pierwotnie miało być zależne od rozdzielczości, ale 
	#udało się ustawić projekt tak, że skaluje się samo
	#Ciągle problem, że najmniejsza czcionka to 8 czyli 24 po przeskalowaniu
	MItems.theme.set_font_size("font_size", "Button", 8)
	MItems.theme.set_stylebox("panel", "TooltipPanel", UiConstants.SbToolTip)
	MItems.theme.set_font_size("font_size", "Label", 8)

func _input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("game_quit"):
		mainmenu_game_quit.emit()
	if Input.is_action_just_pressed("close_current_menu"):
		#Jeśli jakiś inny popup jest aktywny, to pomijamy
		#if (CurrentGameState.CurrentPopup != null) and (CurrentGameState.CurrentPopup != self): 
		#	return
		#else: 
			if visible:
				HideMenu()				
			else:
				ShowMenu()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	
func ShowMenu(WithBackground: bool = BackGroundVisible) -> void:
	#print("show")
	$BackGround.visible = WithBackground
	IsActiveSave = SaveEngine.IsActiveSave()
	SetControls()
	visible = true
	CurrentGameState.CurrentPopup = self
	#print(CurrentGameState.CurrentPopup)
	
func HideMenu() -> void:
	#print("hide")
	#Jeśli jesteśmy na ekranie startowym, to menu zawsze widoczne
	if CurrentGameState.IsStartScreen == false:
		visible = false
		if CurrentGameState.CurrentPopup == self:
			CurrentGameState.CurrentPopup = null
	

func SetControls() -> void:	
	#var IsActiveSave: bool = SaveEngine.IsActiveSave()
	ActiveButoon.grab_focus()
	$BackGround.visible = BackGroundVisible
	$MainMenu/MenuItems/BtnNew.disabled = false
	$MainMenu/MenuItems/BtnContinue.visible = not CurrentGameState.GameIsLoaded
	$MainMenu/MenuItems/BtnContinue.disabled = (not IsActiveSave) and  (not CurrentGameState.GameIsLoaded)
	
	$MainMenu/MenuItems/BtnSave.visible = CurrentGameState.GameIsLoaded
	$MainMenu/MenuItems/BtnSave.disabled = not (CurrentGameState.GameIsLoaded and CurrentGameState.PlayerInSafeZone)
	
	$MainMenu/MenuItems/BtnLoad.disabled = not IsActiveSave
	$MainMenu/MenuItems/BtnOptions.disabled = false
	$MainMenu/MenuItems/BtnQuit.disabled = false
	

func _on_btn_quit_pressed() -> void:
	if CurrentGameState.IsStartScreen == true:
		mainmenu_game_quit.emit()
	else:
		get_tree().change_scene_to_packed(title_scene)

func _on_mainmenu_game_quit() -> void:
	#if $".".visible == true:
		#Tę notyfikację obsłużyć na SaveEngine aby po wywołaniu automatycznie sejwowało
		get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST) 
		get_tree().quit()
		
	
func _on_btn_new_pressed() -> void:
	mainmenu_new_game.emit()


func _on_mainmenu_new_game() -> void:
	$MainMenu/MenuItems/BtnQuit.tooltip_text = "Wyjdź do menu" #to przeniesc do setcontrols
	get_tree().change_scene_to_packed(level_scene)
