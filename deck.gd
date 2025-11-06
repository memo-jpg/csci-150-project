extends Node

var cards : Array = []  #Specify type for clarity

func _ready():
	load_cards("./cards.json")

func load_cards(file_path: String) -> void:
	var file = FileAccess.open(file_path, FileAccess.READ)  #Attempt to open the file

	if (file):  #Check if the file opened successfully
		var data = file.get_as_text()
		print("Data: ", data)  #Read content of the file
		file.close()  #Close the file
		
		var json_parser = JSON.new()  #Create an instance of JSON
		var parse_result = json_parser.parse(data)  #Parse the content
		print(parse_result)
		if (parse_result):
			cards = parse_result.results  #Access the card array
			print(cards)  #Output loaded cards for verification
		else:
			print("Error parsing JSON: ", parse_result, " - ", json_parser.get_error_line())
	else:
		print("Failed to open file: ", file)
