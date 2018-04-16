extends Node2D

# Game config
export(Array) var kColors
export(int) var kNumAreas = 10
export(int) var kAreasStartPos = 600

export(float) var kBackoffTime = 2.0
export(float) var kBackoffSpeed = -5.0

export(float) var kBaseSpeed = 2.0
export(int) var kBaseScore = 100
	# Amount of scored areas to increase multiplier (speed & score)
export(int) var kMultiplierInterval = 1
export(int) var kMaxMultiplier = 10
	# Increase in speed per multiplier (speed is kBaseSpeed + kSpeedIncrease * _multiplier
export(float) var kSpeedIncrease = 1.0
	# Increase in score per multiplier (score is kBaseScore + kScoreIncrease * _multiplier
export(int) var kScoreIncrease = 10

# Player config
export(int) var kLives = 3

# Game state
var _multiplier = 1
var _scoreCount = 0
var _backoffTime = 2.0
var _backingOff = false

# Player state
var _lives = 0
var _score = 0

# Color areas (obstacles)
var _colorAreaScn
var _colorAreas = Array()

func _ready():
	randomize()
	_colorAreaScn = load("res://components/ColorArea.tscn")
	_lives = kLives
	
	for i in range(kNumAreas):
		var colorArea = _colorAreaScn.instance()
		colorArea.position = Vector2(kAreasStartPos + i * 300, 500)
		add_child(colorArea)
		_colorAreas.push_back(colorArea)
		_colorAreas[i].speed = kBaseSpeed

func colorScored():
	_score += kBaseScore + kScoreIncrease * _multiplier
	_scoreCount += 1
	if _scoreCount == kMultiplierInterval:
		_multiplier = min(_multiplier + 1, kMaxMultiplier)
		_scoreCount = 0
		for i in range(kNumAreas):
			_colorAreas[i].speed = kBaseSpeed + kSpeedIncrease * _multiplier

func colorFailed():
	_lives -= 1
	_scoreCount = 0
	if _lives == 0:
		print("Dead with score: " + String(_score))
		resetGame()
	else:
		_backoffTime = kBackoffTime
		_backingOff = true
		for i in range(kNumAreas):
			_colorAreas[i].speed = kBackoffSpeed
	
func resetGame():
	_multiplier = 1
	_lives = kLives
	_score = 0
	for i in range(kNumAreas):
		_colorAreas[i].position = Vector2(kAreasStartPos + i * 300, 500)
		_colorAreas[i].speed = kBaseSpeed
	
func _process(delta):
	if _backingOff == false:
		return
		
	_backoffTime -= delta
	if _backoffTime < 0:
		_backoffTime = 0
		for i in range(kNumAreas):
			_colorAreas[i].speed = kBaseSpeed + kSpeedIncrease * _multiplier
