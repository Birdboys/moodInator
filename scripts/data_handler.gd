extends Node

var time_data_path := "user://time_data.txt"
var mood_data_path := "user://mood_data.txt"
var downloads_dir := OS.get_system_dir(OS.SYSTEM_DIR_DOWNLOADS).path_join("mood_data.csv")
var time_zone_offset := 0
var time_data := {}

func _ready() -> void:
	time_zone_offset = int(Time.get_time_zone_from_system()['bias']*60)
	loadData()
	
func loadData():
	if not FileAccess.file_exists(time_data_path):
		createNewTimeData()
	loadTimeData()
	if not FileAccess.file_exists(mood_data_path):
		createNewMoodData()

func createNewTimeData():
	var new_time_file = FileAccess.open(time_data_path, FileAccess.WRITE)
	var new_time_data = {
		"prev_notice_time":-1,
		"required_time_difference":0,
		"min_cooldown":2,
		"max_cooldown":8,
		"paused":false,
	}
	var time_data_json = JSON.stringify(new_time_data)
	new_time_file.store_line(time_data_json)
	new_time_file.close()
	
func loadTimeData():
	var old_time_file := FileAccess.open(time_data_path, FileAccess.READ)
	var old_time_data = JSON.parse_string(old_time_file.get_as_text())
	time_data = old_time_data.duplicate()
	#time_data['paused'] = bool(time_data['paused'])
	old_time_file.close()
	print(time_data)

func saveTimeData():
	var time_file := FileAccess.open(time_data_path, FileAccess.WRITE)
	var time_data_json = JSON.stringify(time_data)
	time_file.store_line(time_data_json)
	time_file.close()
	
func updateTimeData(time_difference):
	time_data['prev_notice_time'] = getCurrentTime()
	time_data['required_time_difference'] = time_difference
	saveTimeData()
	loadTimeData()

func updateCooldowns(min_cooldown, max_cooldown):
	time_data['min_cooldown'] = min_cooldown
	time_data['max_cooldown'] = max_cooldown
	saveTimeData()
	loadTimeData()

func updatePaused(paused):
	time_data['paused'] = paused
	saveTimeData()
	loadTimeData()
	
func createNewMoodData():
	var new_mood_file = FileAccess.open(mood_data_path, FileAccess.WRITE)
	var mood_data_header = ["mood","date_time"]
	new_mood_file.store_csv_line(mood_data_header)
	new_mood_file.close()
	
func updateMoodData(mood, time):
	var new_mood_data = [mood, time]
	var mood_file = FileAccess.open(mood_data_path, FileAccess.READ_WRITE)
	mood_file.seek_end()
	mood_file.store_csv_line(new_mood_data)
	mood_file.close()
	
func checkTimeReady():
	var current_time = getCurrentTime()
	return current_time-time_data['prev_notice_time'] >= time_data['required_time_difference']

func getCurrentTime():
	return int(Time.get_unix_time_from_system()) + time_zone_offset

func exportMoodData():
	DirAccess.copy_absolute(mood_data_path, downloads_dir)
	#var new_mood_download_file = FileAccess.open(downloads_dir, FileAccess.WRITE)
	#new_mood_download_file.store_csv(mood_data_header)
	#new_mood_download_file.close()
