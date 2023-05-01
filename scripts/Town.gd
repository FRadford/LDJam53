extends StaticBody2D

@export var display_name = ""
@export var town_level = 0

@onready var NextItemTime = Timer.new()

const Item = preload("res://scenes/Item.tscn")
const TownIcon = preload("res://assets/town_marker.png")
const CityIcon = preload("res://assets/city_marker.png")
const inventory_size = 6

var contracts = { } # store "true" inventory here so that multiple interfaces can read it

# Called when the node enters the scene tree for the first time.
func _ready():
	$TownName.text = display_name
	
	match town_level:
		0:
			$Icon.texture = TownIcon
			NextItemTime.wait_time = randf_range(120, 300)
		1:
			$Icon.texture = CityIcon
			NextItemTime.wait_time = randf_range(30, 60)
	
	NextItemTime.autostart = true
	NextItemTime.timeout.connect(_process_next_item)
	add_child(NextItemTime)
	
	# fill inventory with null to create indexes
	for i in range(inventory_size):
		if randi() % 6 == 0:
			contracts[i] = Item.instantiate()
		else:
			contracts[i] = null

func remove_item(index):
	contracts[index] = null

func place_item(index, item):
	contracts[index] = item

func dock_ship():
	return contracts

func add_item(item):
	# TODO: Handle full inventory
	for i in contracts:
		# skip full inventory slots
		if contracts[i] != null:
			continue
		
		contracts[i] = item
		break # break so we only put it into one slot

func _process_next_item():
	add_item(Item.instantiate())
