extends RigidBody2D

var _color = -1

var speed = Vector2(0.0, 15.0)

var lastPhysicsDelta = 0.0

func _ready():
	pass

func setColor(color, colorIdx):
	_color = colorIdx
	get_node("Sprite").modulate = color
	get_node("Sprite").modulate.a = 1.0

func _process(delta):
	pass

func _physics_process(delta):
	lastPhysicsDelta = delta
	
func _integrate_forces(state):
	if position.y > 330:
		speed.y = -15.0
	elif position.y < 310:
		speed.y = 15.0
	
	var pos = state.transform.origin
	pos += speed * lastPhysicsDelta
	state.transform.origin = pos
	lastPhysicsDelta = 0.0
