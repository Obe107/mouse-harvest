extends Control
class_name InventorySlotUI

@onready var texture_rect = $HBoxContainer/TextureRect
@onready var label = $HBoxContainer/Label


func update_slot_ui(slot: InventorySlot):
	if slot.item:
		if slot.item.texture:
			texture_rect.texture = slot.item.texture
		elif !slot.item.texture:
			texture_rect.texture = null
		
		label.text = slot.item.item_name + " x" + str(slot.amount)
	
	else:
		label.text = "Empty slot!"
		texture_rect.texture = null
