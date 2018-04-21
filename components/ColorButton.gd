extends Area2D

export(int) var kColor
export(String) var kKey

var _selected setget setSelected, getSelected

var _mainScene
var _sprite

func _ready():
	_mainScene = get_node("/root/MainScene")
	_sprite = get_node("Sprite")
	_sprite.modulate = _mainScene.kColors[kColor]
	_sprite.modulate.a = 1
	_sprite.frame = 1
	get_node("Label").text = kKey

func setSelected(newVal):
	if newVal == _selected:
		return
		
	if newVal == true:
		get_node("Sprite").frame = 0
	else:
		get_node("Sprite").frame = 1
	_selected = newVal

func getSelected():
	return _selected
	
#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
