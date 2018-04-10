extends RigidBody2D

export(int) var lives = 3
var color = 0 # TODO : Init color as -1 to be able to show "white" ship at beginning?
var score = 0 # TODO : This probably shouldn't be here

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func _process(delta):
	for i in range(get_node("/root/MainScene").COLORS.size()):
		if Input.is_action_pressed("Action"+String(i)):
			color = i
			var newColor = get_node("/root/MainScene").COLORS[i]
			newColor.a = 1.0
			get_node("Sprite").modulate = newColor

func _physics_process(delta):
	# TODO : Add impulses and / or any movement I decide to do
	pass
	
func loseLife():
	lives -= 1
	if lives == 0:
		# TODO Die
		print("DEAD with score :" + String(score))
		score = 0
		lives = 3
		
func gainScore():
	score += 100