extends Control

@export var inventory_res : Inventory

var inventory_slots_ui : Array[InventorySlotUI]
@onready var container = $GridContainer

func _ready():
	# Build UI slot list
	for child in container.get_children():
		inventory_slots_ui.append(child)

	# Connect signal
	inventory_res.inventory_updated.connect(update_all_slots_ui)

	# Initial update
	update_all_slots_ui()


func update_all_slots_ui():
# Iterate with index
	for i in range(len(inventory_res.inventory_slots)):
		var slot = inventory_res.inventory_slots[i]
		#if slot.item:
		inventory_slots_ui[i].update_slot_ui(slot)
