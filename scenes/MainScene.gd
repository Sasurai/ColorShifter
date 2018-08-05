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
var _colorPatterns = [[0, 1, 2, 3, 2, 1, 0],
					  [3, 2, 3, 1, 0, 2, 1],
					  [2, 1, 3, 0, 2, 3, 0],
					  [0, 3, 1, 2, 0, 1, 3],
					  [1, 0, 2, 1, 3, 0, 1],
					  [0, 3, 1, 0, 2, 3, 0],
					  [3, 2, 0, 3, 1, 2, 3],
					  [2, 1, 0, 2, 3, 1, 2]]

var _currentPattern = _colorPatterns[0]
var _currentPatternIndex = -1

func _ready():
	JavaScript.eval("kongregateAPI.loadAPI(function(){ window.kongregate = kongregateAPI.getAPI(); });", true)
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
	# Hack to re-send kong stats (sent on set)
	_persistentData.setAdditionalLives(_persistentData.getAdditionalLives())
	_persistentData.setAdditionalIncoming(_persistentData.getAdditionalIncoming())
	updateLivesDisplay()
	updateFogDisplay()
	updateImprovementsUI()
	get_node("AudioOptsNode/MusicToggle").pressed = _persistentData._playMusic
	get_node("AudioOptsNode/AudioToggle").pressed = _persistentData._playSFX
	_on_MusicToggle_toggled(_persistentData._playMusic)

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
	playSFX(get_node("AudioStreamPlayer3"))
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
	get_node("AnimationPlayer/UpUI/Node2D2/AccumulatedPointsLabel").text = String(_persistentData.getSpendablePoints())

func setMaxScore():
	_persistentData.setMaxScore(_score)
	get_node("AnimationPlayer/UpUI/Node2D2/MaxScoreLabel").text = String(_persistentData.getMaxScore())

func gameFinished():
	_persistentData.submitKongStat("Games Played", 1)
	updateAccumulatedPoints()
	setMaxScore()
	_persistentData.saveGame()
	updateImprovementsUI()
	get_node("AnimationPlayer").play("Close")
	for i in range(kNumAreas):
		_colorAreas[i].position = Vector2(-1000, 500)
		_colorAreas[i].speed = 0
	
	updateLivesDisplay()
	
func colorFailed():
	playSFX(get_node("AudioStreamPlayer2"))
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
	
	for i in range(kColors.size()):
		get_node("Node2D/ColorButton" + String(i)).setSelected(false)

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

func getNextColor():
	_currentPatternIndex += 1
	if _currentPatternIndex == _currentPattern.size():
		_currentPattern = _colorPatterns[randi() % _colorPatterns.size()]
		_currentPatternIndex = 0

	return _currentPattern[_currentPatternIndex]

func updateImprovementsUI():
	var additionalLives = _persistentData.getAdditionalLives()
	if additionalLives == _persistentData.kMaxLives:
		get_node("AnimationPlayer/UpUI/Node2D/AddLifeLabel").text = "SOLD OUT"
		get_node("AnimationPlayer/UpUI/Node2D/BuyLifeButton").disabled = true
		get_node("AnimationPlayer/UpUI/Node2D/NotEnoughLifeTxt").visible = false
	else:
		get_node("AnimationPlayer/UpUI/Node2D/AddLifeLabel").text = String(_persistentData.kLifeUpgradeCosts[additionalLives])
		if _persistentData.kLifeUpgradeCosts[additionalLives] < _persistentData.getSpendablePoints():
			get_node("AnimationPlayer/UpUI/Node2D/BuyLifeButton").disabled = false
			get_node("AnimationPlayer/UpUI/Node2D/NotEnoughLifeTxt").visible = false
		else:
			get_node("AnimationPlayer/UpUI/Node2D/BuyLifeButton").disabled = true
			get_node("AnimationPlayer/UpUI/Node2D/NotEnoughLifeTxt").visible = true
			
	var additionalIncoming = _persistentData.getAdditionalIncoming()
	if additionalIncoming == _persistentData.kMaxIncoming:
		get_node("AnimationPlayer/UpUI/Node2D/ClearFogLabel").text = "SOLD OUT"
		get_node("AnimationPlayer/UpUI/Node2D/TextureButton2").disabled = true
		get_node("AnimationPlayer/UpUI/Node2D/NotEnoughFogTxt").visible = false
	else:
		get_node("AnimationPlayer/UpUI/Node2D/ClearFogLabel").text = String(_persistentData.kLifeUpgradeCosts[additionalIncoming])
		if _persistentData.kLifeUpgradeCosts[additionalIncoming] < _persistentData.getSpendablePoints():
			get_node("AnimationPlayer/UpUI/Node2D/TextureButton2").disabled = false
			get_node("AnimationPlayer/UpUI/Node2D/NotEnoughFogTxt").visible = false
		else:
			get_node("AnimationPlayer/UpUI/Node2D/TextureButton2").disabled = true
			get_node("AnimationPlayer/UpUI/Node2D/NotEnoughFogTxt").visible = true

func _on_PlayButton_pressed():
	get_node("AnimationPlayer").play("Open")
	resetGame()

func _on_BuyLifeButton_pressed():
	var additionalLives = _persistentData.getAdditionalLives()
	if additionalLives == _persistentData.kMaxLives:
		return
	
	if _persistentData.kLifeUpgradeCosts[additionalLives] < _persistentData.getSpendablePoints():
		_persistentData.buyAdditionalLife()
		playSFX(get_node("AudioStreamPlayer4"))

	_persistentData.saveGame()
	
	updateImprovementsUI()
	get_node("AnimationPlayer/UpUI/Node2D2/AccumulatedPointsLabel").text = String(_persistentData.getSpendablePoints())
	updateLivesDisplay()

func _on_TextureButton2_pressed():
	var additionalIncoming = _persistentData.getAdditionalIncoming()
	if additionalIncoming == _persistentData.kMaxIncoming:
		return
	
	if _persistentData.kFogUpgradeCosts[additionalIncoming] < _persistentData.getSpendablePoints():
		_persistentData.buyAdditionalIncoming()
		playSFX(get_node("AudioStreamPlayer4"))

	_persistentData.saveGame()
	
	updateImprovementsUI()
	get_node("AnimationPlayer/UpUI/Node2D2/AccumulatedPointsLabel").text = String(_persistentData.getSpendablePoints())
	updateFogDisplay()


func _on_MusicToggle_toggled(button_pressed):
	_persistentData._playMusic = button_pressed
	if button_pressed == false:
		get_node("AudioStreamPlayer").stop()
	else:
		get_node("AudioStreamPlayer").play()

func _on_AudioToggle_toggled(button_pressed):
	_persistentData._playSFX = button_pressed

func playSFX(node):
	if _persistentData._playSFX == true:
		node.play()