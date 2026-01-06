extends Control

@onready var backButton := $backMargin/backButton
@onready var exportButton := $optionsMargin/optionsVbox/exportButton

@onready var pauseButton := $optionsMargin/optionsVbox/pauseCheckbox
@onready var minEntry := $optionsMargin/optionsVbox/minMarign/minVbox/minHbox/minEntry
@onready var minLabel := $optionsMargin/optionsVbox/minMarign/minVbox/minHbox/minLabel
@onready var maxEntry := $optionsMargin/optionsVbox/minMarign/minVbox/maxHbox/maxEntry
@onready var maxLabel := $optionsMargin/optionsVbox/minMarign/minVbox/maxHbox/maxLabel

signal toggle_options

func _ready() -> void:
	backButton.pressed.connect(emit_signal.bind("toggle_options"))
	exportButton.pressed.connect(DataHandler.exportMoodData)
	pauseButton.toggled.connect(pauseUpdated)
	minEntry.value_changed.connect(minUpdated)
	maxEntry.value_changed.connect(maxUpdated)
	#setSliders()
	
func minUpdated(min_value):
	min_value = int(min_value)
	minLabel.text = str(min_value)
	if min_value > maxEntry.value:
		maxEntry.set_value_no_signal(min_value)
		maxLabel.text = str(min_value)
	DataHandler.updateCooldowns(minEntry.value, maxEntry.value)

func maxUpdated(max_value):
	max_value = int(max_value)
	maxLabel.text = str(max_value)
	if max_value < minEntry.value:
		minEntry.set_value_no_signal(max_value)
		minLabel.text = str(max_value)
	DataHandler.updateCooldowns(minEntry.value, maxEntry.value)
	
func setSliders():
	minEntry.set_value_no_signal(DataHandler.time_data['min_cooldown'])
	maxEntry.set_value_no_signal(DataHandler.time_data['max_cooldown'])
	minLabel.text = str(int(DataHandler.time_data['min_cooldown']))
	maxLabel.text = str(int(DataHandler.time_data['max_cooldown']))
	
func pauseUpdated(paused:bool):
	DataHandler.updatePaused(paused)

func setPause():
	pauseButton.set_pressed_no_signal(DataHandler.time_data['paused'])
