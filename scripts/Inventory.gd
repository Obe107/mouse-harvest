extends Resource
class_name Inventory

signal inventory_updated

@export var inventory_slots : Array[InventorySlot]



func insert_item(item: InventoryItem, amount: int):
		# Check if item is stackable and already exists in the inventory
		for slot in inventory_slots:
			#if slot.item == item and slot.amount < item.max_stack:
			if slot.item == item:
				
				# Add the amount to the existing stack (but don't exceed max_stack)
				#var new_amount = min(slot.amount + amount, item.max_stack)
				#amount -= new_amount - slot.amount
				#slot.amount = new_amount
				
				# Logic Without Max Stack
				slot.amount += amount
				
				#updated.emit()
				print("Collected an item thats already in the inventory! New Amount: ", slot.amount)
				inventory_updated.emit()
				
				# If there's still more amount to add, continue to next slot
				#if amount <= 0:
				#	return
				return
	
		# If item is not found or cannot stack, add new items to the next available slot
		for i in range(inventory_slots.size()):
			if !inventory_slots[i].item: # If slot is empty
				# Add remaining amount of the item
				inventory_slots[i].item = item
				inventory_slots[i].amount = amount
				#updated.emit()
				print("New item added to inv slot: ", inventory_slots[i])
				inventory_updated.emit()
				
				#if i == global.currently_selected:
					#print("Collected Item Held")
				#	hold_item.emit(item)
				return


func remove_item(item: InventoryItem, amount: int) -> void:
	for slot in inventory_slots:
		if amount <= 0:
			break
		
		# If this slot contains the item, remove as much as we can
		if slot.item == item:
			var diff = slot.amount - amount
			
			slot.amount = max(slot.amount - amount, 0)
			print("Removed ", amount, " ", item.item_name, " from the inv!")
			
			if diff <= 0:
				#slot.item = Items.EMPTY
				slot.item = null
				print("No items left, inv slot cleared!")
				# Here's the leftover amount we need to remove
				amount = abs(diff)
			else:
				amount = 0
		
		inventory_updated.emit()
