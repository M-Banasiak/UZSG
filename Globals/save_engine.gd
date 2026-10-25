extends Node

#zapis ręczny (Zapisz/Wczytaj) i autozapis przy wyjściu z gry, czysty tekst JSON
#user:// = %APPDATA%\Godot\app_userdata\UZSG
const SAVE_PATH: String = "user://savegame.json"
const AUTOSAVE_PATH: String = "user://autosave.json"
const SAVE_VERSION: int = 1

#ustawiane przed przejściem do levelu, level po _ready wczytuje stan z tego pliku
var load_path: String = ""

#jakikolwiek zapis (Kontynuuj)
func IsActiveSave() -> bool:
	return HasManualSave() or FileAccess.file_exists(AUTOSAVE_PATH)

#zapis ręczny (Wczytaj)
func HasManualSave() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

#nowszy z zapisów (Kontynuuj); "" jeśli brak
func NewestSavePath() -> String:
	var newest: String = ""
	for path: String in [SAVE_PATH, AUTOSAVE_PATH]:
		if FileAccess.file_exists(path) and (newest.is_empty() or
				FileAccess.get_modified_time(path) > FileAccess.get_modified_time(newest)):
			newest = path
	return newest

func SaveGame(data: Dictionary, path: String = SAVE_PATH) -> bool:
	data["version"] = SAVE_VERSION
	var file: FileAccess = FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("SaveEngine: nie można zapisać " + path + " (" + error_string(FileAccess.get_open_error()) + ")")
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	#print("SaveEngine: zapisano " + ProjectSettings.globalize_path(path))
	return true

#autozapis przy zamknięciu gry (okno / game_quit z MainMenu rozsyła to powiadomienie)
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		AutoSave()

#autozapis bieżącej rozgrywki, w tle bez komunikatu; poza levelem nic nie robi
func AutoSave() -> void:
	var level: Node = get_tree().current_scene
	if CurrentGameState.GameIsLoaded and level != null and level.has_method("get_save_data"):
		SaveGame(level.get_save_data(), AUTOSAVE_PATH)

func LoadGame(path: String = SAVE_PATH) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var text: String = FileAccess.get_file_as_string(path)
	var data = JSON.parse_string(text)
	if not data is Dictionary:
		push_error("SaveEngine: uszkodzony plik zapisu " + path)
		return {}
	return data

#Vector2 <-> [x, y], bo JSON nie zna typów Godota
func vec_to_json(v: Vector2) -> Array:
	return [v.x, v.y]

func json_to_vec(a: Array) -> Vector2:
	return Vector2(a[0], a[1])
