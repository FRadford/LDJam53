extends PanelContainer

const SlotClass = preload("res://scripts/InventorySlot.gd")
const ItemClass = preload("res://scripts/Item.gd")
@onready var inventory_slots = $InventoryPanel/VBoxContainer/Body/InventorySlots
var held_item = null
var hovered_item = null

signal item_picked(item: ItemClass, index: int)
signal item_placed(item: ItemClass, index: int)
signal inventory_open


# Called when the node enters the scene tree for the first time.
func _ready():
	for slot in inventory_slots.get_children():
		slot.gui_input.connect(_process_slot_input.bind(slot))
		slot.mouse_entered.connect(_process_slot_entered.bind(slot))
		slot.mouse_exited.connect(_process_slot_exited.bind(slot))

func _process(delta):
	if hovered_item:
		$InventoryPanel/VBoxContainer/Body/Sidebar/PanelContainer/VBoxContainer/HBoxContainer/Value.text = str(hovered_item.item_value) + "g"

func add_item(slot_index: int, item: ItemClass):
	var slot = $InventoryPanel/VBoxContainer/Body/InventorySlots.get_child(slot_index)
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
					emit_signal("item_placed", held_item, slot.get_index())
					
					held_item = null
				else: # swap held item for clicked item
					var temp_item = slot.item
					slot.pick_from_slot()
					temp_item.global_position = get_global_mouse_position() - Vector2(32, 32)
					slot.put_into_slot(held_item)
					emit_signal("item_placed", held_item, slot.get_index())
					
					held_item = temp_item
			elif slot.item: # pickup item from slot
				held_item = slot.item
				slot.pick_from_slot()
				held_item.global_position = get_global_mouse_position() - Vector2(32, 32)
				emit_signal("item_picked", held_item, slot.get_index())

func _input(event):
	if held_item:
		held_item.global_position = get_global_mouse_position() - Vector2(32, 32)

func _on_inventory_button_toggled(button_pressed):
	if button_pressed:
		$InventoryPanel.visible = true
		get_tree().paused = true
		emit_signal("inventory_open")
	else:
		$InventoryPanel.visible = false
		get_tree().paused = false
		
		# clear slots so the items are free for other interfaces
		for slot in inventory_slots.get_children():
			slot.clear()


func _on_ui_close_button_pressed():
	$InventoryPanel.visible = false
	$InventoryButton.button_pressed = false
	get_tree().paused = false
	hovered_item = null
	
	# clear slots so the items are free for other interfaces
	for slot in inventory_slots.get_children():
		slot.clear()
