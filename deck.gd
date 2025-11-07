extends Node

var cards : Array = []  #Specify type for clarity

func _ready():
	load_cards("res://cards.json")

func load_cards(file_path: String) -> void:
	var file = FileAccess.open(file_path, FileAccess.READ)  #Attempt to open the file

	if (file):  #Check if the file opened successfully
		var data = file.get_as_text()
		print("Data: ", data)  #Read content of the file
		file.close()  #Close the file
		
		var json_parser = JSON.new()  #Create an instance of JSON
		var parse_result = json_parser.parse(data)  #Parse the content
		print(parse_result)
		if (parse_result == OK):
			var json_data = json_parser.get_data()  #Access the card array
			var card_list = json_data["cards"]
			
			for card_dict in card_list:
				var card_obj = Cards.new()
				card_obj.setID(card_dict["id"])
				card_obj.setType(card_dict["type"])
				card_obj.setName(card_dict["cardName"])
				card_obj.setDamage(card_dict["damage"])
				card_obj.setShield(card_dict["shield"])
				card_obj.setEnergyCost(card_dict["energyCost"])
				
				cards.append(card_obj)
				print("Loaded Cards: ", card_obj.cardName)  #Output loaded cards for verification
		else:
			print("Error parsing JSON: ", parse_result, " - ", json_parser.get_error_message())
	else:
		print("Failed to open file: ", file)
