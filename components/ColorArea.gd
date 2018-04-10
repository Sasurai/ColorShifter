extends Area2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"
export(float) var speed = 10.0

var color = 0

func _ready():
	color = randi() % get_node("/root/MainScene").COLORS.size()
	get_node("Sprite").modulate = get_node("/root/MainScene").COLORS[color]


func _process(delta):
	# Called every frame. Delta is time since last frame.
	# Update game logic here.
	pass

func _physics_process(delta):
	position.x -= speed
	if position.x < -40:
		position.x = 3000
		color = randi() % get_node("/root/MainScene").COLORS.size()
		get_node("Sprite").modulate = get_node("/root/MainScene").COLORS[color]

# TODO : Connect area_entered or body_entered depending if player is area or physicsbody (prob area on first iter)

func _on_ColorArea_body_entered(body):
	if body.color == color:
		body.gainScore()
		pass
	else:
		body.loseLife()
		# TODO pain
		pass

