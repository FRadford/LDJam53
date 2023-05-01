extends Panel

var highlight_active: bool = false
var error_active: bool = false

var item = null

@export var parent_inventory : Control
@export var inventory_type : String

# Called when the node enters the scene tree for the first time.
func _ready():
	$Highlight.visible = highlight_active

func _process(delta):
	$Highlight.visible = highlight_active

func pick_from_slot():
	$CenterContainer.remove_child(item)
	parent_inventory.add_child(item)
	item = null

func put_into_slot(new_item):
	item = new_item
	item.position = Vector2(0, 0)
	parent_inventory.remove_child(item)
	$CenterContainer.add_child(item)
	
func set_error():
	error_active = true
	$Error.visible = error_active

func clear_error():
	error_active = false
	$Error.visible = error_active

# remove the item from the node tree so that other interfaces can use it
func clear():
	if item:
		$CenterContainer.remove_child(item)
		item = null

func destroy():
	$CenterContainer.remove_child(item)
	item.queue_free()
	item = null
