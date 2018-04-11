extends RigidBody2D

var color = 0 # TODO : Init color as -1 to be able to show "white" ship at beginning?

var speed = Vector2(0.0, 15.0)

var lastPhysicsDelta = 0.0

var _mainScene

func _ready():
	_mainScene = get_node("/root/MainScene")

func _process(delta):
	for i in range(_mainScene.kColors.size()):
		if Input.is_action_pressed("Action"+String(i)):
			color = i
			var newColor = _mainScene.kColors[i]
			newColor.a = 1.0
			get_node("Sprite").modulate = newColor

func _physics_process(delta):
	lastPhysicsDelta = delta
	
func _integrate_forces(state):
	if position.y > 310:
		speed.y = -15.0
	elif position.y < 290:
		speed.y = 15.0
	
	var pos = state.transform.origin
	pos += speed * lastPhysicsDelta
	state.transform.origin = pos
	lastPhysicsDelta = 0.0
