extends PanelContainer

const SlotClass = preload("res://scripts/InventorySlot.gd")
const ItemClass = preload("res://scripts/Item.gd")
@onready var player_inventory = $InventoryPanel/VBoxContainer/Body/PlayerInventory
@onready var town_contracts = $InventoryPanel/VBoxContainer/Body/TownInventory/VBoxContainer/TownContracts
@onready var town_dropoff = $InventoryPanel/VBoxContainer/Body/TownInventory/VBoxContainer/DropOff
var held_item = null
var hovered_item = null
var town = ""

signal item_picked(item: ItemClass, index: int, inventory_type: String)
signal item_placed(item: ItemClass, index: int, inventory_type: String)
signal panel_closed


# Called when the node enters the scene tree for the first time.
func _ready():
	for slot in player_inventory.get_children():
		slot.gui_input.connect(_process_slot_input.bind(slot))
		slot.mouse_entered.connect(_process_slot_entered.bind(slot))
		slot.mouse_exited.connect(_process_slot_exited.bind(slot))
	
	for slot in town_contracts.get_children():
		slot.gui_input.connect(_process_slot_input.bind(slot))
		slot.mouse_entered.connect(_process_slot_entered.bind(slot))
		slot.mouse_exited.connect(_process_slot_exited.bind(slot))
	
	town_dropoff.gui_input.connect(_process_slot_input.bind(town_dropoff))
	town_dropoff.mouse_entered.connect(_process_slot_entered.bind(town_dropoff))
	town_dropoff.mouse_exited.connect(_process_slot_exited.bind(town_dropoff))
	
func _process(delta):
	if hovered_item:
		$InventoryPanel/VBoxContainer/Body/Sidebar/PanelContainer/VBoxContainer/HBoxContainer/Value.text = str(hovered_item.item_value) + "g"

func set_town_name(town_name):
	town = town_name
	$InventoryPanel/VBoxContainer/Header/PanelContainer/HBoxContainer/Label.text = town_name
	
func add_town_item(slot_index: int, item: ItemClass):
	var slot = $InventoryPanel/VBoxContainer/Body/TownInventory/VBoxContainer/TownContracts.get_child(slot_index)
	slot.put_into_slot(item)
	
func add_player_item(slot_index: int, item: ItemClass):
	var slot = $InventoryPanel/VBoxContainer/Body/PlayerInventory.get_child(slot_index)
	slot.put_into_slot(item)

func _process_slot_entered(slot: SlotClass):
	# highlight slot + update sidebar information
	slot.highlight_active = true
	
	if slot.item:
		hovered_item = slot.item
		$InventoryPanel/VBoxContainer/Body/Sidebar/PanelContainer/VBoxContainer/Title.text = slot.item.item_name
		$InventoryPanel/VBoxContainer/Body/Sidebar/PanelContainer/VBoxContainer/Description.text = slot.item.item_description
		$InventoryPanel/VBoxContainer/Body/Sidebar/PanelContainer/VBoxContainer/Destination.text = slot.item.item_destination
		$InventoryPanel/VBoxContainer/Body/Sidebar/PanelContainer/VBoxContainer/HBoxContainer/Value.text = str(slot.item.item_value) + "g"
	
func _process_slot_exited(slot: SlotClass):
	# deselect slot + update sidebar info
	slot.highlight_active = false
	hovered_item = null

func _process_slot_input(event: InputEvent, slot: SlotClass):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT && event.pressed:
			if held_item != null:
				if !slot.item: # drop held item into slot
					slot.put_into_slot(held_item)
					emit_signal("item_placed", held_item, slot.get_index(), slot.inventory_type)
					held_item = null
					
				else: # swap held item for clicked item
					var temp_item = slot.item
					slot.pick_from_slot()
					temp_item.global_position = get_global_mouse_position() - Vector2(32, 32)
					slot.put_into_slot(held_item)
					emit_signal("item_placed", held_item, slot.get_index(), slot.inventory_type)
					held_item = temp_item
				
				# check if dropoff item is correct
				if slot.inventory_type == "dropoff":
					if slot.item.item_destination == town:
						# remove item if matched
						slot.destroy()
					else:
						# this item doesn't go here
						slot.set_error()
			
			elif slot.item: # pickup item from slot
				held_item = slot.item
				slot.pick_from_slot()
				held_item.global_position = get_global_mouse_position() - Vector2(32, 32)
				emit_signal("item_picked", held_item, slot.get_index(), slot.inventory_type)
				
				# clear error from dropoff when item picked up
				if slot.inventory_type == "dropoff":
					slot.clear_error()

func _input(event):
	if held_item:
		held_item.global_position = get_global_mouse_position() - Vector2(32, 32)


func _on_close_button_pressed():
	# clear slots so the items are free for other interfaces
	for slot in player_inventory.get_children():
		slot.clear()
	# clear slots so the items are free for other interfaces
	for slot in town_contracts.get_children():
		slot.clear()

	emit_signal("panel_closed")
