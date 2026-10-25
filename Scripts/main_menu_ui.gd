extends CanvasLayer

class_name  MainMenu

var level_scene: PackedScene = preload("res://Scenes/Levels/level.tscn")
var title_scene: PackedScene = preload("res://Scenes/title_scene.tscn")
var crosshair_cursor: Texture2D = preload("res://Res/Graphics/Misc/crosshair.png")
const CROSSHAIR_HOTSPOT: Vector2 = Vector2(12, 12) #środek celownika 24x24

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
		#Esc na okienku "Zapisano grę" działa jak OK
		if $SavedPopup.visible:
			_on_saved_popup_ok_pressed()
			return
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
	#w menu domyślny kursor
	Input.set_custom_mouse_cursor(null)
	#menu w trakcie gry pauzuje rozgrywkę (MainMenu ma process_mode Always)
	get_tree().paused = not CurrentGameState.IsStartScreen
	#print(CurrentGameState.CurrentPopup)
	
func HideMenu() -> void:
	#print("hide")
	#Jeśli jesteśmy na ekranie startowym, to menu zawsze widoczne
	if CurrentGameState.IsStartScreen == false:
		visible = false
		if CurrentGameState.CurrentPopup == self:
			CurrentGameState.CurrentPopup = null
		#w grze celownik
		Input.set_custom_mouse_cursor(crosshair_cursor, Input.CURSOR_ARROW, CROSSHAIR_HOTSPOT)
		get_tree().paused = false
	

func SetControls() -> void:	
	#var IsActiveSave: bool = SaveEngine.IsActiveSave()
	ActiveButoon.grab_focus()
	$BackGround.visible = BackGroundVisible
	$MainMenu/MenuItems/BtnNew.disabled = false
	#w menu pauzy BtnNew wznawia grę zamiast zaczynać nową
	if CurrentGameState.IsStartScreen:
		$MainMenu/MenuItems/BtnNew.text = "MENU_NEW"
		$MainMenu/MenuItems/BtnNew.tooltip_text = "MENU_NEW_TIP"
	else:
		$MainMenu/MenuItems/BtnNew.text = "MENU_CONTINUE"
		$MainMenu/MenuItems/BtnNew.tooltip_text = "MENU_RESUME_TIP"
	$MainMenu/MenuItems/BtnContinue.visible = not CurrentGameState.GameIsLoaded
	$MainMenu/MenuItems/BtnContinue.disabled = (not IsActiveSave) and  (not CurrentGameState.GameIsLoaded)
	
	$MainMenu/MenuItems/BtnSave.visible = CurrentGameState.GameIsLoaded
	#PlayerInSafeZone na razie nigdzie nie jest ustawiane, więc zapis dostępny zawsze w trakcie gry
	$MainMenu/MenuItems/BtnSave.disabled = not CurrentGameState.GameIsLoaded
	
	#Kontynuuj wczytuje nowszy z zapisów, Wczytaj tylko zapis ręczny
	$MainMenu/MenuItems/BtnLoad.disabled = not SaveEngine.HasManualSave()
	$MainMenu/MenuItems/BtnOptions.disabled = false
	$MainMenu/MenuItems/BtnLanguage.disabled = false
	$MainMenu/MenuItems/BtnQuit.disabled = false
	

#przełącza pl <-> en; teksty z kluczami (Res/Localization/translations.csv) odświeżają się same
func _on_btn_language_pressed() -> void:
	if TranslationServer.get_locale().begins_with("pl"):
		TranslationServer.set_locale("en")
	else:
		TranslationServer.set_locale("pl")

func _on_btn_save_pressed() -> void:
	var level: Node = get_tree().current_scene
	if level.has_method("get_save_data"):
		if SaveEngine.SaveGame(level.get_save_data()):
			$SavedPopup.show()
			$SavedPopup/Panel/Margin/Items/BtnOk.grab_focus()

#OK na okienku "Zapisano grę" - wyjście z menu i powrót do gry
func _on_saved_popup_ok_pressed() -> void:
	$SavedPopup.hide()
	HideMenu()

func _on_btn_load_pressed() -> void:
	load_saved_game(SaveEngine.SAVE_PATH)

func _on_btn_continue_pressed() -> void:
	load_saved_game(SaveEngine.NewestSavePath())

#przeładowuje level, który po starcie nakłada stan z pliku (SaveEngine.load_path)
func load_saved_game(path: String) -> void:
	if path.is_empty() or not FileAccess.file_exists(path):
		return
	SaveEngine.load_path = path
	get_tree().paused = false #pauza nie może przejść do nowej sceny
	get_tree().change_scene_to_packed(level_scene)

func _on_btn_quit_pressed() -> void:
	if CurrentGameState.IsStartScreen == true:
		mainmenu_game_quit.emit()
	else:
		SaveEngine.AutoSave() #wyjście z gry do menu głównego
		get_tree().paused = false #pauza nie może przejść do nowej sceny
		get_tree().change_scene_to_packed(title_scene)

func _on_mainmenu_game_quit() -> void:
	#if $".".visible == true:
		#SaveEngine obsługuje tę notyfikację - autozapis rozgrywki przed wyjściem
		get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST) 
		get_tree().quit()
		
	
func _on_btn_new_pressed() -> void:
	if CurrentGameState.IsStartScreen:
		mainmenu_new_game.emit()
	else:
		HideMenu()


func _on_mainmenu_new_game() -> void:
	$MainMenu/MenuItems/BtnQuit.tooltip_text = "MENU_QUIT_TO_TITLE_TIP" #to przeniesc do setcontrols
	get_tree().paused = false #pauza nie może przejść do nowej sceny
	get_tree().change_scene_to_packed(level_scene)
