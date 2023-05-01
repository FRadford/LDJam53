extends Node2D

@onready var DeliveryTime = Timer.new()

const destinations = ["Kingston", "San Juan", "Basseterre", "Saint John's", "Montego Bay", "Santiago", "Nassau", "Havana", "Port au Prince", "Santo Domingo"]
var item_id
var item_name
var item_description
var item_destination
var item_value

# Called when the node enters the scene tree for the first time.
func _ready():
	if randi() % 2 == 0:
		item_id = "letter"
	else:
		item_id = "parcel"
	
	$MarginContainer/Texture.texture = load("res://assets/items/" + item_id + ".png")
	item_name = JsonData.item_data[item_id]["display_name"]
	item_description = JsonData.item_data[item_id]["description"]
	item_destination = destinations[randi() % destinations.size()]
	item_value = JsonData.item_data[item_id]["value"]
	
	# set time to item_value
	DeliveryTime.wait_time = item_value
	DeliveryTime.one_shot = true
	DeliveryTime.autostart = true
	
	add_child(DeliveryTime)

func _process(delta):
	$MarginContainer/TimeLeft.text = str(int(DeliveryTime.time_left))
	item_value = int(DeliveryTime.time_left)
