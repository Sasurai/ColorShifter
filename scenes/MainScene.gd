extends Node2D

# Game config
export(Array) var kColors
export(int) var kNumAreas = 10
export(int) var kAreasStartPos = 600

export(float) var kBackoffTime = 2.0
export(float) var kBackoffSpeed = -5.0

export(float) var kBaseSpeed = 2.0
export(int) var kBaseSeparation = 450

export(int) var kBaseScore = 50

	# Amount of scored areas to increase multiplier (speed & score)
export(int) var kMultiplierInterval = 2
export(int) var kMaxMultiplier = 10
	# Increase in speed per multiplier (speed is kBaseSpeed + kSpeedIncrease * _multiplier
export(float) var kSpeedIncrease = 1.0
export(int) var kSeparationDecrease = 50
	# Increase in score per multiplier (score is kBaseScore + kScoreIncrease * _multiplier
export(int) var kScoreIncrease = 20

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

# Persistent data
var _persistentData

# Color patterns
var _colorPatterns = [[0, 1, 2, 3], [3, 2, 3, 1, 0, 3], [2, 1, 3, 0, 2], [0, 3, 1, 2, 0, 1, 3], [1, 0, 2, 1, 3, 0, 1]]
var _currentPattern = _colorPatterns[0]
var _currentPatternIndex = -1

func _ready():
	_persistentData = get_node("/root/PersistentData")
	randomize()
	_colorAreaScn = load("res://components/ColorArea.tscn")
	for i in range(kNumAreas):
		var colorArea = _colorAreaScn.instance()
		colorArea.position = Vector2(-1000, 500)
		colorArea.speed = 0
		add_child(colorArea)
		_colorAreas.push_back(colorArea)
	
	# Initialize UI with data read from save game
	setMaxScore()
	updateAccumulatedPoints()
	updateLivesDisplay()
	updateFogDisplay()

func updateLivesDisplay():
	_lives = _persistentData._additionalLives + 1
	for i in range(1, _lives):
		get_node("AnimationPlayer/UpUI/Node2D2/LifeBarLight"+String(i)).lifeAvailable()
	for i in range(_lives, _persistentData.kMaxLives + 1):
		get_node("AnimationPlayer/UpUI/Node2D2/LifeBarLight"+String(i)).lifeUnavailable()

func updateFogDisplay():
	if _persistentData._additionalIncoming > 0:
		get_node("AnimationPlayer2/Fog1").visible = false
	if _persistentData._additionalIncoming > 1:
		get_node("AnimationPlayer2/Fog2").visible = false
	if _persistentData._additionalIncoming > 2:
		get_node("AnimationPlayer2/Fog3").visible = false

func colorScored():
	_score += kBaseScore + kScoreIncrease * _multiplier
	get_node("AnimationPlayer/UpUI/Node2D2/ScoreLabel").text = String(_score)
	_scoreCount += 1
	if _scoreCount == kMultiplierInterval:
		_multiplier = min(_multiplier + 1, kMaxMultiplier)
		_scoreCount = 0
		for i in range(kNumAreas):
			_colorAreas[i].speed = kBaseSpeed + kSpeedIncrease * _multiplier

func updateAccumulatedPoints():
	_persistentData.updateAccumulatedPoints(_score)
	get_node("AnimationPlayer/UpUI/Node2D2/AccumulatedPointsLabel").text = String(_persistentData.getAccumulatedPoints())

func setMaxScore():
	_persistentData.setMaxScore(_score)
	get_node("AnimationPlayer/UpUI/Node2D2/MaxScoreLabel").text = String(_persistentData.getMaxScore())

func gameFinished():
	updateAccumulatedPoints()
	setMaxScore()
	_persistentData.saveGame()
	get_node("AnimationPlayer").play("Close")
	for i in range(kNumAreas):
		_colorAreas[i].position = Vector2(-1000, 500)
		_colorAreas[i].speed = 0
	
	updateLivesDisplay()
	
func colorFailed():
	_lives -= 1
	if _lives > 0:
		get_node("AnimationPlayer/UpUI/Node2D2/LifeBarLight"+String(_lives)).lifeLost()
	_scoreCount = 0
	if _lives == 0:
		gameFinished()
		
	else:
		_backoffTime = kBackoffTime
		_backingOff = true
		for i in range(kNumAreas):
			_colorAreas[i].speed = kBackoffSpeed
	
func resetGame():
	_multiplier = 1
	updateLivesDisplay()
	updateFogDisplay()
		
	_score = 0
	get_node("AnimationPlayer/UpUI/Node2D2/ScoreLabel").text = String(_score)
	for i in range(kNumAreas):
		_colorAreas[i].position = Vector2(kAreasStartPos + i * kBaseSeparation, 500)
		_colorAreas[i].speed = kBaseSpeed
	
	get_node("Player").setColor(Color(1.0, 1.0, 1.0, 1.0), -1)
	
func _process(delta):
	for i in range(kColors.size()):
		if Input.is_action_pressed("Action"+String(i)):
			var prevColorIdx = get_node("Player")._color
			var newColor = kColors[i]
			get_node("Player").setColor(newColor, i)
			get_node("Node2D/ColorButton" + String(i)).setSelected(true)
			if prevColorIdx > -1 and prevColorIdx != i:
				get_node("Node2D/ColorButton" + String(prevColorIdx)).setSelected(false)

			
	if _backingOff == false:
		return
		
	_backoffTime -= delta
	if _backoffTime < 0:
		_backingOff = false
		_backoffTime = 0
		for i in range(kNumAreas):
			_colorAreas[i].speed = kBaseSpeed + kSpeedIncrease * _multiplier

func getColorAreaResetPosition():
	return (kNumAreas * kBaseSeparation) - (kSeparationDecrease * _multiplier)

# TODO : Better color generation, something like:
	# - Have a set of patterns defined
	# - Do a random to select a pattern and play that full pattern, then select a new one
	# - First and final color need to be single (no repetition)
func getNextColor():
	_currentPatternIndex += 1
	if _currentPatternIndex == _currentPattern.size():
		_currentPattern = _colorPatterns[randi() % _colorPatterns.size()]
		_currentPatternIndex = 0

	return _currentPattern[_currentPatternIndex]


func _on_PlayButton_pressed():
	get_node("AnimationPlayer").play("Open")
	resetGame()
