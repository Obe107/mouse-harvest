extends Control

@export var inventory_res : Inventory
@export var slot_scene: PackedScene  # assign InventorySlotUI.tscn in Inspector

var inventory_slots_ui : Array[InventorySlotUI]
@onready var container = %SlotContainer

func _ready():
	# Build UI slot list
	#for child in container.get_children():
	#	inventory_slots_ui.append(child)

	# Connect signal
	inventory_res.inventory_updated.connect(update_all_slots_ui)

	# Initial update
	update_all_slots_ui()


#func update_all_slots_ui():
# Iterate with index
#	for i in range(len(inventory_res.inventory_slots)):
#		var slot = inventory_res.inventory_slots[i]
#		#if slot.item:
#		inventory_slots_ui[i].update_slot_ui(slot)

func update_all_slots_ui():
	# Add more UI slots if inventory grew
	while inventory_slots_ui.size() < inventory_res.inventory_slots.size():
		var new_slot: InventorySlotUI = slot_scene.instantiate()
		container.add_child(new_slot)
		inventory_slots_ui.append(new_slot)
	
	# Update all slots
	for i in range(inventory_res.inventory_slots.size()):
		inventory_slots_ui[i].update_slot_ui(inventory_res.inventory_slots[i])
