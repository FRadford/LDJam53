extends Node

var item_data: Dictionary

# Called when the node enters the scene tree for the first time.
func _ready():
	item_data = load_data("res://data/items.json")


func load_data(file_path):
	var file_data = FileAccess.open(file_path, FileAccess.READ)
	var json_data = JSON.parse_string(file_data.get_as_text())
	
	return json_data
