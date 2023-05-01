extends CharacterBody2D

const SPEED = 200

const Item = preload("res://scenes/Item.tscn")
const ItemClass = preload("res://scripts/Item.gd")

@export var inventory_size = 15

var town_in_range
var inventory = {} # store "true" inventory here so that multiple interfaces can read it
var gold_total = 15

func _ready():
	$CoinDisplay.set_count(gold_total)
	
	# fill inventory with null to create indexes
	for i in range(inventory_size):
		inventory[i] = null
	
	# add one item to start
	var new_item = Item.instantiate()
	add_item(new_item)

func add_item(item: ItemClass):
	# TODO: Handle full inventory
	for i in inventory:
		# skip full inventory slots
		if inventory[i] != null:
			continue
		
		inventory[i] = item
		break # break so we only put it into one slot

func update_town_panel(town_inventory):
	$TownPanel.set_town_name(town_in_range.display_name)
	
	for i in town_inventory:
		if town_inventory[i] != null:
			$TownPanel.add_town_item(i, town_inventory[i])
	for i in inventory:
		if inventory[i] != null:
			$TownPanel.add_player_item(i, inventory[i])

func update_inventory_panel():
	for i in inventory:
		if inventory[i] != null:
			$ShipInventory.add_item(i, inventory[i])

func _physics_process(delta):
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction_x = Input.get_axis("ship_left", "ship_right")
	var direction_y = Input.get_axis("ship_up", "ship_down")
	
	
	
	if direction_x:
		velocity.x = direction_x * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if direction_y:
		velocity.y = direction_y * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)

	move_and_slide()
	
func _input(event):
	if event.is_action_pressed("ship_left"):
		$Sprite2D.flip_h = false
	elif event.is_action_pressed("ship_right"):
		$Sprite2D.flip_h = true
	elif event.is_action_pressed("ship_dock") and town_in_range:
		var town_inventory = town_in_range.dock_ship()
		update_town_panel(town_inventory)
		$TownPanel.visible = true
		$ShipInventory.visible = false
		get_tree().paused = true
	elif event.is_action_pressed("pause"):
		$PauseMenu.visible = true
		$ShipInventory.visible = false
		$CoinDisplay.visible = false
		get_tree().paused = true

func _on_docking_range_body_entered(body):
	if body.is_in_group("town"):
		town_in_range = body


func _on_docking_range_body_exited(body):
	if body.is_in_group("town"):
		town_in_range = null

func _on_ship_inventory_item_picked(item, index):
	# remove item from inventory array
	inventory[index] = null


func _on_ship_inventory_item_placed(item, index):
	# put item at given index in inventory array
	inventory[index] = item


func _on_town_panel_closed():
	$ShipInventory.visible = true
	$TownPanel.visible = false
	get_tree().paused = false


func _on_ship_inventory_open():
	update_inventory_panel()


func _on_town_panel_item_picked(item, index, inventory_type):
	if inventory_type == "player":
		# remove item from inventory array
		inventory[index] = null
	elif inventory_type == "contract":
		# remove item from town contract array
		town_in_range.remove_item(index)


func _on_town_panel_item_placed(item, index, inventory_type):
	if inventory_type == "player":
		# put item at given index in inventory array
		inventory[index] = item
	elif inventory_type == "contract":
		town_in_range.place_item(index, item)
	elif inventory_type == "dropoff":
		if item.item_destination == town_in_range.display_name:
			gold_total += item.item_value
			$CoinDisplay.set_count(gold_total)


func _on_pause_menu_resume():
	$ShipInventory.visible = true
	$CoinDisplay.visible = true
