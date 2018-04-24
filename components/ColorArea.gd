extends Area2D

export(float) var speed = 10.0

var _mainScene
var color = 0

func _ready():
	_mainScene = get_node("/root/MainScene")
	color = randi() % _mainScene.kColors.size()
	get_node("Sprite").modulate = _mainScene.kColors[color]

func _physics_process(delta):
	position.x -= speed
	if position.x < -40:
		position.x = _mainScene.getColorAreaResetPosition()
		color = randi() % _mainScene.kColors.size()
		get_node("Sprite").modulate = _mainScene.kColors[color]

func _on_ColorArea_body_entered(body):
	if body._color == color:
		_mainScene.colorScored()
	else:
		_mainScene.colorFailed()

