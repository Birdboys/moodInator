extends Control

@onready var titleLabel := $moodMargin/moodVbox/titleLabel
@onready var joyButton := $moodMargin/moodVbox/moodButtonHbox/joyButton
@onready var happyButton := $moodMargin/moodVbox/moodButtonHbox/happyButton
@onready var neutralButton := $moodMargin/moodVbox/moodButtonHbox/neutralButton
@onready var sadButton := $moodMargin/moodVbox/moodButtonHbox/sadButton
@onready var awfulButton := $moodMargin/moodVbox/moodButtonHbox/awfulButton
@onready var optionsButton := $optionsMargin/optionsButton
signal mood_pressed(mood)
signal toggle_options

func _ready() -> void:
	joyButton.pressed.connect(moodPressed.bind("joy"))
	happyButton.pressed.connect(moodPressed.bind("happy"))
	neutralButton.pressed.connect(moodPressed.bind("neutral"))
	sadButton.pressed.connect(moodPressed.bind("sad"))
	awfulButton.pressed.connect(moodPressed.bind("awful"))
	optionsButton.pressed.connect(emit_signal.bind("toggle_options"))
	
func toggleButtonsOn(on:=true):
	joyButton.disabled = not on
	happyButton.disabled = not on
	neutralButton.disabled = not on
	sadButton.disabled = not on
	awfulButton.disabled = not on
	
	joyButton.modulate = Color("9c524e") if on else Color("a99c8d")
	happyButton.modulate = Color("b97a60") if on else Color("a99c8d")
	neutralButton.modulate = Color("cca87b") if on else Color("a99c8d")
	sadButton.modulate = Color("5b7d73") if on else Color("a99c8d")
	awfulButton.modulate = Color("4e5463") if on else Color("a99c8d")
	
	titleLabel.text = "CHOOSE YOUR MOOD" if on else "MOODS ON COOLDOWN"

func moodPressed(mood):
	toggleButtonsOn(false)
	emit_signal("mood_pressed", mood)
