extends Node

var tilemap_layers = []

# Dictionary to track crops on the crop layer
# Key: Vector2 grid_coords
# Value: Dictionary with crop data (seed item, current stage, timer)
var crops := {}

# Define a layer enum
enum Layer {
	FARMLAND = 0,
	GROUND = 1,
	CROPS = 2,
	DECOR = 3
}

# Map item types to default layers
var type_to_layer := {
	TileItem.TileItemType.FARMLAND: Layer.FARMLAND,
	TileItem.TileItemType.GROUND: Layer.GROUND,
	TileItem.TileItemType.CROPS: Layer.CROPS,
	TileItem.TileItemType.DECOR: Layer.DECOR
}

func setup(_tilemap_layers):
	tilemap_layers = _tilemap_layers


func place_tile(grid_coords: Vector2, tile_item: TileItem) -> void:
	# Determine the correct layer automatically
	var layer = type_to_layer.get(tile_item.tile_type, Layer.DECOR)
	
	# Get the current tile at the target position and layer
	var existing_tile = BetterTerrain.get_cell(tilemap_layers[layer], grid_coords)

	# If there's already a tile here, don't place another
	if existing_tile != -1:
		print("Skipped placing at " + str(grid_coords) + " on layer " + str(layer) + " (tile already exists)")
		return
	
	# If this is a farmland, check if there is grass above (layer 1)
	if tile_item.tile_type == TileItem.TileItemType.FARMLAND:
		var grass_tile = BetterTerrain.get_cell(tilemap_layers[Layer.GROUND], grid_coords)
		if grass_tile != -1:
			# Remove the grass tile above
			BetterTerrain.set_cell(tilemap_layers[Layer.GROUND], grid_coords, -1)
			BetterTerrain.update_terrain_cell(tilemap_layers[Layer.GROUND], grid_coords, true)



	# If this is a crop, check if there is farmland below (layer 0)
	if tile_item.tile_type == TileItem.TileItemType.CROPS:
		var farmland_tile = BetterTerrain.get_cell(tilemap_layers[Layer.FARMLAND], grid_coords)
		if farmland_tile == -1:
			print("Cannot plant crop at", grid_coords, "- no farmland below!")
			return  # skip planting if no farmland
		
		# Track crop in dictionary
		print("Crop Item Placed!")
		crops[grid_coords] = {
			"seed": tile_item,
			"current_stage": 0,
			"timer": 0.0,
			"fully_grown": false,
			"growth_time": tile_item.growth_time * randf_range(0.9, 1.1)  # ±10%
		}

	# Place the tile visually
	print("Placing a tile with tile_index " + str(tile_item.tile_index) + " at " + str(grid_coords) + " on layer " + str(layer))
	BetterTerrain.set_cell(tilemap_layers[layer], grid_coords, tile_item.tile_index)


func remove_tile(grid_coords: Vector2, layer: int) -> void:
	# Get the current tile at the target position and layer
	var existing_tile = BetterTerrain.get_cell(tilemap_layers[layer], grid_coords)

	# If there isn's a tile here, we don't remove it
	if existing_tile == -1:
		print("Skipped removing at " + str(grid_coords) + " on layer " + str(layer) + " (there is no tile there)")
		return
	
	# Otherwise, remove the tile
	print("Removing a tile at" + str(grid_coords) + " on layer " + str(layer))
	BetterTerrain.set_cell(tilemap_layers[layer], grid_coords, -1)
	
	# If a crop existed here, remove it from the crops dictionary
	if crops.has(grid_coords):
		crops.erase(grid_coords)


func _process(delta):
	update_crops(delta)


func update_crops(delta: float) -> void:
	for grid_coords in crops.keys():
		var crop_data = crops[grid_coords]
		var seed_item: CropItem = crop_data["seed"]

		# Increment growth timer
		crop_data["timer"] += delta

		# Calculate which stage it should be in
		#var stage_duration = crop_data["growth_time"] / seed_item.growth_stages
		var stage_duration = (crop_data["growth_time"] / seed_item.growth_stages) * randf_range(0.8, 1.2)

		var new_stage = int(crop_data["timer"] / stage_duration)

		# Clamp new_stage to maximum stage
		if new_stage >= seed_item.growth_stages:
			new_stage = seed_item.growth_stages - 1

		# Update tile if stage increased
		if new_stage > crop_data["current_stage"]:
			crop_data["current_stage"] = new_stage
			var tile_index = seed_item.tile_index + new_stage
			BetterTerrain.set_cell(tilemap_layers[2], grid_coords, tile_index)

			# Check if fully grown
			if crop_data["current_stage"] == seed_item.growth_stages - 1:
				# Mark as fully grown
				crop_data["fully_grown"] = true
				print("Tile at", grid_coords, "is fully grown!")


func harvest_crop(grid_coords: Vector2):
	if not crops.has(grid_coords):
		print("No crop here!")
		return # nothing to harvest

	var crop_data = crops[grid_coords]

	if crop_data["fully_grown"]:
		# Give player items here (from crop_data["seed"])
		print("Harvested crop at", grid_coords)

		# Remove tile visually
		BetterTerrain.set_cell(tilemap_layers[2], grid_coords, -1)

		# Remove from dictionary
		crops.erase(grid_coords)
	else:
		print("Crop is not fully grown yet!")
