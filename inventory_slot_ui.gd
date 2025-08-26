extends Control
class_name InventorySlotUI

@onready var texture_rect = $HBoxContainer/TextureRect
@onready var label = $HBoxContainer/Label

var item_in_this_slot : InventoryItem

func update_slot_ui(slot: InventorySlot):
	if slot.item:
		if slot.item.texture:
			texture_rect.texture = slot.item.texture
		elif !slot.item.texture:
			texture_rect.texture = null
		
		label.text = slot.item.item_name + " x" + str(slot.amount)
		
		item_in_this_slot = slot.item
	
	else:
		label.text = "Empty slot!"
		texture_rect.texture = null


func _on_pressed():
	Global.selected_item = item_in_this_slot
