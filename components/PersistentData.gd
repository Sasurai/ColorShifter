extends Node2D

# Player config
var kMaxLives = 3

var _additionalLives = 2 setget setAdditionalLives, getAdditionalLives
var _additionalIncoming = 0
var _maxScore = 0 setget setMaxScore, getMaxScore
var _accumulatedPoints = 0 setget updateAccumulatedPoints, getAccumulatedPoints
var _spentPoints = 0 setget spendPoints, getSpentPoints

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	# Ideally here we should read from Kong
	pass

func setAdditionalLives(lives):
	_additionalLives = max(0, min(lives, kMaxLives))
	
func getAdditionalLives():
	return _additionalLives
	
func setMaxScore(score):
	if score > _maxScore:
		_maxScore = score
	# Write to disk / kong on game end

func getMaxScore():
	return _maxScore
	
func updateAccumulatedPoints(points):
	_accumulatedPoints += points
	
func getAccumulatedPoints():
	return _accumulatedPoints

func spendPoints(points):
	_spentPoints += points
	# Write to disk / kong on upgrade bought

func getSpentPoints():
	return _spentPoints

func getAvailablePoints():
	return _accumulatedPoints - _spentPoints