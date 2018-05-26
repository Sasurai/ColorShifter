extends CenterContainer

signal play_pressed

var _improvementsLabel
var _imprSeparator
var _imprMenu
	
func _ready():
	_improvementsLabel = get_node("HBoxContainer/VBoxContainer/ImprovementsLabel")
	_imprSeparator = get_node("HBoxContainer/VSeparator")
	_imprMenu = get_node("HBoxContainer/Improvements")

func improvementsMenuClicked():
	if get_node("HBoxContainer/Improvements").visible == true:
		_imprSeparator.visible = false
		_imprMenu.visible = false
		_improvementsLabel.add_color_override("font_color", Color(1, 1, 1))
	else:
		_imprSeparator.visible = true
		_imprMenu.visible = true
		_improvementsLabel.add_color_override("font_color", Color(1, 0.3, 0.3))

func _on_ImprovementsLabel_gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		improvementsMenuClicked()


func _on_PlayLabel_gui_input(event):
	if event is InputEventMouseButton and event.button_index == BUTTON_LEFT and event.pressed:
		emit_signal("play_pressed")
