extends GutTest

var Cards = preload("res://mapDev/Cards.gd")
var tempCard: Cards


func before_each() -> void: # before each unit test
	# hero = Hero.new()
	tempCard = Cards.new()
	# add_child(hero)
	add_child(tempCard)
	# await get_tree().process_frame
	await get_tree().process_frame

func after_each() -> void:
	#hero.queue_free()
	tempCard.queue_free()
	


#func test_isActive
func test_cardName() -> void:
	#assert_eq(hero.health, hero.max_health, "Hero should start with full health.")
	print(tempCard.cardName)
	assert_eq(tempCard.cardName, "Default Card Name", "Name expected to be \"Default Card Name\"")
	pass
	
func test_cardType() -> void:
	
	assert_eq(tempCard.type, "None", "Card type expected to be \"None\"")
