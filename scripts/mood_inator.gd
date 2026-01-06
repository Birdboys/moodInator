extends Control

@export var channel_id := "mood_channel"
@export var channel_name := "THE MOOD CHANNEL"
@export var channel_description:= "My Channel Description"
@export var channel_importance:= NotificationChannel.Importance.DEFAULT

@export var message_id := 1
@export var message_title := "MESSAGE TITLE"
@export var message_text := "PLEASE WORK OH MY GOD"

@onready var setupScreen := $setupScreen
@onready var moodEntryScreen := $moodEntryScreen
@onready var optionsScreen := $optionsScreen

@onready var permButton := $setupScreen/setupBG/setupMargins/setupButtons/permButton
@onready var batteryButton := $setupScreen/setupBG/setupMargins/setupButtons/batteryButton

@onready var notifScheduler := $NotificationScheduler

var notification_delay := 1
var mood_delay_min := 2 * 3600
var mood_delay_max := 8 * 3600

func _ready() -> void:
	toggleSetup(true)
	toggleOptions(false)
	moodEntryScreen.mood_pressed.connect(moodPressed)
	moodEntryScreen.toggle_options.connect(toggleOptions.bind(true))
	batteryButton.pressed.connect(notifScheduler.request_ignore_battery_optimizations_permission)
	permButton.pressed.connect(notifScheduler.request_post_notifications_permission)
	optionsScreen.toggle_options.connect(toggleOptions.bind(false))
	
	notifScheduler.initialization_completed.connect(notifInitComplete)
	notifScheduler.post_notifications_permission_granted.connect(notifPermGranted)
	notifScheduler.post_notifications_permission_denied.connect(notifPermDenied)
	notifScheduler.battery_optimizations_permission_granted.connect(batteryPermGranted)
	notifScheduler.battery_optimizations_permission_denied.connect(batteryPermDenied)
	notifScheduler.initialize()
	
	checkReady()
	
func toggleSetup(on:=true):
	setupScreen.visible = on
	moodEntryScreen.visible = not on

func toggleOptions(on:=true):
	optionsScreen.visible = on
	if on:
		optionsScreen.setSliders()
		optionsScreen.setPause()
	else:
		checkReady()
	
func moodPressed(mood):
	DataHandler.updateMoodData(mood, DataHandler.getCurrentTime())
	var mood_delay_time := randi_range(DataHandler.time_data['min_cooldown'], DataHandler.time_data['max_cooldown']) * 3600
	scheduleMoodActivation(mood_delay_time)

func scheduleMoodActivation(time):
	sendMessage("MOODS REACTIVATED", "Time to mark your mood", time)
	DataHandler.updateTimeData(time)
	get_tree().quit()
	
func newMoodTime():
	moodEntryScreen.toggleButtonsOn(true)

func checkReady():
	if DataHandler.checkTimeReady() and not DataHandler.time_data['paused']:
		moodEntryScreen.toggleButtonsOn(true)
	else:
		moodEntryScreen.toggleButtonsOn(false)
		
func notifInitComplete() -> void:
	#outputText("NOTIFICATION SCHEDULER INITIALIZED")
	if notifScheduler.has_post_notifications_permission():
		#outputText("HAS NOTIFICATION PERMISSIONS")
		createChannel()
		if checkPermsGranted():
			allPermsGranted()
	else:
		permButton.disabled = false
	
	if notifScheduler.is_ignoring_battery_optimizations():
		#outputText("HAS BATTERY PERMISSIONS")
		if checkPermsGranted():
			allPermsGranted()
	else:
		batteryButton.disabled = false

func notifPermDenied(_permission_name: String) -> void:
	#outputText("NOTIFICATION PERMISSIONS DENIED")
	permButton.disabled = false

func notifPermGranted(_permission_name: String) -> void:
	#outputText("NOTIFICATION PERMISSIONS GRANTED, MESSAGE TIME")
	createChannel()
	permButton.disabled = true
	if checkPermsGranted():
			allPermsGranted()

func batteryPermDenied(_permission_name: String) -> void:
	#outputText("BATTERY PERMISSIONS DENIED")
	batteryButton.disabled = false

func batteryPermGranted(_permission_name: String) -> void:
	#outputText("BATTERY PERMISSIONS GRANTED, MESSAGE TIME")
	batteryButton.disabled = true
	if checkPermsGranted():
		allPermsGranted()

func createChannel():
	#outputText("Creating notification channel.")
	var _result = notifScheduler.create_notification_channel(
			NotificationChannel.new()
					.set_id(channel_id)
					.set_name(channel_name)
					.set_description(channel_description)
					.set_importance(channel_importance))

func sendMessage(title, text, delay:=0):
	var notification_data = NotificationData.new()\
			.set_id(message_id)\
			.set_channel_id(channel_id)\
			.set_title(title)\
			.set_content(text)\
			.set_delay(delay)

	notification_data.set_large_icon_name(NotificationScheduler.DEFAULT_ICON_NAME)
	notification_data.set_small_icon_name(NotificationScheduler.DEFAULT_ICON_NAME)
	#__notification_data.set_custom_data(CustomData.new().set_int_property("my_test_int", 14)
		#.set_string_property("my_test_string", "just testing"))

	#outputText("Scheduling notification with text: %s" % message_text)

	notifScheduler.schedule(notification_data)

func checkPermsGranted():
	return notifScheduler.has_post_notifications_permission() and notifScheduler.is_ignoring_battery_optimizations()

func allPermsGranted():
	toggleSetup(false)
	sendMessage("SUCCESS", "Successfully granted notification permissions")
