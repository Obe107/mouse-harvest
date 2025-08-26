extends InventoryItem
class_name TileItem

@export var tile_index : int = -1 # Used only if item is TILE
@export var tile_type: TileItemType = TileItemType.OTHER


enum TileItemType {
	GROUND,
	FARMLAND,
	CROPS,
	DECOR,

	OTHER
}

var tile_type_strings = {
	TileItemType.GROUND: "Ground Tile",
	TileItemType.FARMLAND: "Farmland",
	TileItemType.CROPS: "CROPS",
	TileItemType.DECOR: "DECOR",

	TileItemType.OTHER: "Other"
}



func get_tile_type_as_string() -> String:
	return type_strings.get(type, "Unknown")
