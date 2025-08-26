extends Node2D

@onready var tilemap_layers = [  # Reference each TileMapLayer node directly
	$TileMap/FarmlandTileLayer, $TileMap/GrassTileLayer, $TileMap/CropsTileLayer, $TileMap/DecorTileLayer
]

@onready var player_inv_gui = $Camera2D/InventoryGUI
@onready var debug_label = $Camera2D/Label

var placing_tile := false
var removing_tile := false
var harvesting_tile := false
var moving_camera := false
var last_mouse_pos := Vector2.ZERO
# Zoom limits
const MIN_ZOOM := 1
const MAX_ZOOM := 3.0
const ZOOM_STEP := 0.1

var grid_size := 16
var last_grid_coords = null

# Load items
var farmland_item: InventoryItem = preload("res://items/farmland.tres")
var tool_item: InventoryItem = preload("res://items/tool.tres")
var object_item: InventoryItem = preload("res://items/object.tres")
var crop_item: CropItem = preload("res://items/crop.tres")
var crop_item2: CropItem = preload("res://items/crop2.tres")

var player_inv: Inventory = preload("res://player_inv.tres")


func _ready():
	TileManager.setup(tilemap_layers)
	generate_map()




func generate_map() -> void:
	# Loop through rows (y-axis)
	for y in range(50):
		# Loop through columns (x-axis)
		for x in range(50):
			# Grid coordinates for this cell
			var grid_coords = Vector2(x, y)

			# Place a tile at this position
			BetterTerrain.set_cell(tilemap_layers[1], grid_coords, 1)
			BetterTerrain.update_terrain_cell(tilemap_layers[1], grid_coords, true)


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if Global.selected_item.type == InventoryItem.ItemType.TILE:
				placing_tile = event.pressed # true when pressed down, false when released
				last_grid_coords = null
			
			elif Global.selected_item.type == InventoryItem.ItemType.BREAK_TILE:
				removing_tile = event.pressed
				last_grid_coords = null
		
		if event.button_index == MOUSE_BUTTON_RIGHT:
			harvesting_tile = event.pressed
			last_grid_coords = null
		
		if event.button_index == MOUSE_BUTTON_MIDDLE:
			moving_camera = event.pressed
			if moving_camera:
				# Save the starting position of the mouse when pressed
				last_mouse_pos = get_global_mouse_position()
	
		# Scroll zoom
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			$Camera2D.zoom = Vector2.ONE * clamp($Camera2D.zoom.x - ZOOM_STEP, MIN_ZOOM, MAX_ZOOM)
		
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			$Camera2D.zoom = Vector2.ONE * clamp($Camera2D.zoom.x + ZOOM_STEP, MIN_ZOOM, MAX_ZOOM)

		
	if event is InputEventMouseMotion and moving_camera:
		# Calculate how much the mouse moved since last frame
		var mouse_delta = event.relative
		# Move the camera in the opposite direction of mouse movement (dragging)
		#$Camera2D.position -= event.relative * 0.8  # slower drag
		# Move camera opposite to mouse drag
		$Camera2D.position -= event.relative / $Camera2D.zoom.x


	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_1:
				Global.selected_item = farmland_item
				print("Selected:", Global.selected_item.item_name)
			KEY_2:
				Global.selected_item = tool_item
				print("Selected:", Global.selected_item.item_name)
			KEY_3:
				Global.selected_item = crop_item
				print("Selected:", Global.selected_item.item_name)
			KEY_4:
				Global.selected_item = crop_item2
				print("Selected:", Global.selected_item.item_name)
			
			KEY_8:
				player_inv.insert_item(farmland_item, 1)
				
			KEY_9:
				player_inv.remove_item(farmland_item, 1)




func _process(delta: float) -> void:
	var grid_coords = (get_global_mouse_position() / grid_size).floor()
	if placing_tile: 	# Only place a tile if the mouse is being held down
		if grid_coords != last_grid_coords: 	# Check if we've moved into a new cell before placing
			TileManager.place_tile(grid_coords, Global.selected_item, player_inv)
			last_grid_coords = grid_coords

	elif removing_tile:
		if grid_coords != last_grid_coords:
			TileManager.remove_tile(grid_coords, 1)
			last_grid_coords = grid_coords
	
	elif harvesting_tile:
		if grid_coords != last_grid_coords:
			TileManager.harvest_crop(grid_coords)
			last_grid_coords = grid_coords

	if Global.selected_item:
		debug_label.text = Global.selected_item.item_name
	else:
		debug_label.text = "Null Item Selected"
