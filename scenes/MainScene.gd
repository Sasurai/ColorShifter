extends Node2D

export(Array) var COLORS
export(int) var numAreas = 10

var colorAreaScn

var colorAreas = Array()

func _ready():
	randomize()
	colorAreaScn = load("res://components/ColorArea.tscn")
	
	for i in range(numAreas):
		var colorArea = colorAreaScn.instance()
		colorArea.position = Vector2(i * 300, 500)
		add_child(colorArea)
		colorAreas.push_back(colorArea)
		colorAreas[i].speed = 2

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
