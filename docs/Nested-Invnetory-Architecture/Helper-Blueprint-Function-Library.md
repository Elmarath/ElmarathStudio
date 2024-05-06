---
sidebar_position: 4
---

# Blueprint Function Library Helper

This class will help you to *Debug*, *Edit*, *Get Information about* the given inventory.

While you are customizing your inventory system, creating a new UI or equipment system; there are many helpful functions to use in here.

## All of the Functions

| Function Name | Parameters | Return | Description |
| --- | --- | --- | --- |
| `GetDebugStringFromInventory` | `const FString& TitleOfInventory, const FInventory& InputInventory` | `FString` | Returns a debug string for the given inventory. |
| `GetRandomItemStaticDataFromSettings` | `FGameplayTag ItemTag, bool bUseExactTagMatch, const TArray<UItemStaticData*>& ItemStaticDataArray` | `UItemStaticData*` | Returns a random item static data from the settings array that matches the given tag. |
| `GetInventoryFromTemplateInventory` | `const FTemplateInventory& TemplateInventory, UInventoryManagerComponent* InvManagerComp` | `FInventory` | Creates an inventory from the template inventory. |
| `CoordsToIndex` | `FIntPoint Point, FIntPoint GridSize` | `int32` | Returns the index of the given point in the grid. |
| `IndexToCoords` | `int Index, FIntPoint GridSize` | `FIntPoint` | Returns the coordinates of the given index in the grid. |
| `GetIndicesInRect` | `int StartIndex, FIntPoint TargetRectSize, FIntPoint ContainerGridSize` | `TArray<int32>` | Returns the indices of the rectangle in the grid. |
| `CanRectangleFitInContainer` | `int StartIndex, FIntPoint TargetRectToFit, FIntPoint ContainerGridSize` | `bool` | Checks if the given rectangle can fit in the container grid. |
| `GetInventoryGridSize` | `const FInventory& Inventory` | `FIntPoint` | Returns the size of the inventory grid. |
| `GetProjectedIndicesFromCoords` | `int32 StartIndex, FIntPoint HoveringItemGridSize, FIntPoint ContainerGridSize` | `TArray<int32>` | Returns the projected indices of the hovering item in the container grid. |
| `GetNumberOfItemsWillBeLeftAfterDrag` | `const FSlotAddressWithSystem& SourceSlotAddress, ETargetTransactionType TransactionType` | `int32` | Returns the number of items that will be left after a drag operation. |
| `GetNumberOfItemsWillBeDragged` | `const FSlotAddressWithSystem& SourceSlotAddress, ETargetTransactionType TransactionType` | `int32` | Returns the number of items that will be dragged. |
| `GetParentGameplayTags` | `FGameplayTag GameplayTag` | `TArray<FGameplayTag>` | Returns the parent tags of the given tag. |
| `GetSectionsAvailableForItemData` | `const FInventory& Inventory, const FItemStaticInfo& ItemStaticData` | `TArray<int32>` | Returns the indexes of the sections that can hold the given item static data. |
| `DoesHaveAnySlot` | `UInventorySystem* InventorySystem` | `bool` | Checks if the inventory has any slots. |
| `GetInventorySection` | `const FInventory& Inventory, int32 SectionIndex` | `FInventorySection` | Returns the inventory section that matches the given index. |
| `GetInventorySlotFromAddress` | `const FSlotAddressWithSystem& SlotAddress` | `FInventorySlot` | Returns the inventory slot that matches the given address. |
| `GetItemsInSlot` | `const FSlotAddressWithSystem& SlotAddress` | `TArray<UInventoryItem*>` | Returns the items in the slot that matches the given address. |
| `GetInventoryAddressOfItem` | `const FInventory& Inventory, const UInventoryItem* Item` | `FSlotAddress` | Returns the address of the item if the given inventory item is in the inventory system. |
| `GetAllItemsInInventory` | `const FInventory& Inventory, bool bIncludeNestedItems` | `TArray<UInventoryItem*>` | Returns all the items that are in the inventory system. |
| `CreateInventoryItemFromStaticData` | `UItemStaticData* ItemStaticData, UPayloadTemplate* ItemPayloadTemplateOverride, UInventoryManagerComponent* InvManagerComp` | `UInventoryItem*` | Creates a new inventory item from the given static data and payload template override. |