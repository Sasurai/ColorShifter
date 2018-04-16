extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export(float) var speed = 10.0

var _mainScene
var color = 0

func _ready():
	_mainScene = get_node("/root/MainScene")
	color = randi() % _mainScene.kColors.size()
	get_node("Sprite").modulate = _mainScene.kColors[color]


func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	pass

func _physics_process(delta):
	position.x -= speed
	if position.x < -40:
		position.x = 3000
		color = randi() % _mainScene.kColors.size()
		get_node("Sprite").modulate = _mainScene.kColors[color]

# TODO : Connect area_entered or body_entered depending if player is area or physicsbody (prob area on first iter)

func _on_ColorArea_body_entered(body):
	if body._color == color:
		_mainScene.colorScored()
	else:
		_mainScene.colorFailed()

