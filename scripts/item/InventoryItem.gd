extends Resource
class_name InventoryItem

@export_category("Display")

@export var item_name: String = ""
#@export var desc: String = ""
@export var type: ItemType = ItemType.OTHER
#@export var texture: Texture2D

#@export_category("Properties")
#@export var max_stack: int = 999


enum ItemType {
	BREAK_TILE,
	TILE,

	OTHER
}

var type_strings = {
	ItemType.BREAK_TILE: "Tool",
	ItemType.TILE: "Tile",

	ItemType.OTHER: "Other"
}



func get_type_as_string() -> String:
	return type_strings.get(type, "Unknown")
