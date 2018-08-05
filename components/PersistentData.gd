extends Node2D

# Player config
var kMaxLives = 3
var kMaxIncoming = 3

var kLifeUpgradeCosts = [150, 1500, 20000]
var kFogUpgradeCosts = [150, 1500, 20000]

var _additionalLives = 0 setget setAdditionalLives, getAdditionalLives
var _additionalIncoming = 0 setget setAdditionalIncoming, getAdditionalIncoming
var _maxScore = 0 setget setMaxScore, getMaxScore
var _accumulatedPoints = 0 setget updateAccumulatedPoints, getAccumulatedPoints
var _spentPoints = 0 setget spendPoints, getSpentPoints

var _playMusic = true
var _playSFX = true

var kSaveFileName = "user://colorshifter.save"
var kPassword = "p7s8w1d3C8l5rShf2"

var kAdditionalLivesKey = "adl"
var kAdditionalIncomingKey = "adi"
var kMaxScoreKey = "msc"
var kAccumulatedPointsKey = "acp"
var kSpentPointsKey = "spp"
var kPlayMusicKey = "pms"
var kPlaySFXKey = "psfx"

func submitKongStat(stat, value):
	JavaScript.eval("kongregate.stats.submit('"+ stat +"', "+String(value)+");", true)

func _ready():
	loadSavedGame()
	pass

func buyAdditionalLife():
	spendPoints(kLifeUpgradeCosts[_additionalLives])
	setAdditionalLives(_additionalLives + 1)
	
func buyAdditionalIncoming():
	spendPoints(kFogUpgradeCosts[_additionalIncoming])
	setAdditionalIncoming(_additionalIncoming + 1)

func setAdditionalLives(lives):
	_additionalLives = max(0, min(lives, kMaxLives))
	submitKongStat("Additional Lives Bought", _additionalLives)
	if _additionalLives == kMaxLives and _additionalIncoming == kMaxIncoming:
		submitKongStat("AllUpgradesBought", 1)
	
func getAdditionalLives():
	return _additionalLives

func setAdditionalIncoming(incoming):
	_additionalIncoming = max(0, min(incoming, kMaxIncoming))
	submitKongStat("Additional Incoming Bought", _additionalIncoming)
	if _additionalLives == kMaxLives and _additionalIncoming == kMaxIncoming:
		submitKongStat("AllUpgradesBought", 1)
	
func getAdditionalIncoming():
	return _additionalIncoming

func setMaxScore(score):
	submitKongStat("Highest Score", score)
	if score > _maxScore:
		_maxScore = score
	# Write to disk + send event to kong on game end

func getMaxScore():
	return _maxScore
	
func updateAccumulatedPoints(points):
	submitKongStat("Earned Chips", points * 0.1)
	_accumulatedPoints += points * 0.1
	
func getAccumulatedPoints():
	return _accumulatedPoints

func getSpendablePoints():
	return _accumulatedPoints - _spentPoints
	
func spendPoints(points):
	_spentPoints += points
	# Write to disk + send event to kong on upgrade bought

func getSpentPoints():
	return _spentPoints

func getAvailablePoints():
	return _accumulatedPoints - _spentPoints
	
func loadSavedGame():
	var saveFile = File.new()
	if not saveFile.file_exists(kSaveFileName):
		return
	
	saveFile.open_encrypted_with_pass (kSaveFileName, File.READ, kPassword)
	
	var saveDict = parse_json(saveFile.get_line())
	_additionalLives = saveDict[kAdditionalLivesKey]
	_additionalIncoming = saveDict[kAdditionalIncomingKey]
	_maxScore = saveDict[kMaxScoreKey]
	_accumulatedPoints = saveDict[kAccumulatedPointsKey]
	_spentPoints = saveDict[kSpentPointsKey]
	_playMusic = saveDict[kPlayMusicKey]
	_playSFX = saveDict[kPlaySFXKey]
	saveFile.close()
	
func saveGame():
	# Create save dictionary
	var saveDict = {
		kAdditionalLivesKey : _additionalLives,
		kAdditionalIncomingKey : _additionalIncoming,
		kMaxScoreKey : _maxScore,
		kAccumulatedPointsKey : _accumulatedPoints,
		kSpentPointsKey : _spentPoints,
		kPlayMusicKey : _playMusic,
		kPlaySFXKey : _playSFX
	}
	
	var saveFile = File.new()
	saveFile.open_encrypted_with_pass (kSaveFileName, File.WRITE, kPassword)
	saveFile.store_line(to_json(saveDict))
	
	saveFile.close()
