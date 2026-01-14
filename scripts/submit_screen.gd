extends CanvasLayer

@onready var yesButton := $panel/submitMargin/submitVbox/buttonHbox/yesButton
@onready var noButton := $panel/submitMargin/submitVbox/buttonHbox/noButton
@onready var submitLabel := $panel/submitMargin/submitVbox/submitLabel

signal choice_made(yes:bool)

func _ready() -> void:
	closeMenu()
	yesButton.pressed.connect(choiceMade.bind(true))
	noButton.pressed.connect(choiceMade.bind(false))

func loadMenu(mood):
	visible = true
	submitLabel.text = "SUBMIT MOOD\n%s" % mood.to_upper()
	
func closeMenu():
	visible = false

func choiceMade(yes:bool):
	emit_signal("choice_made", yes)
	closeMenu()
