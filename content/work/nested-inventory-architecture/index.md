---
title: Nested Inventory Architecture
tagline: A replicated, object-based inventory for Unreal Engine where any item can hold its own inventory, from backpacks inside backpacks to attachments inside weapons.
kind: Plugin
role: "Solo developer: architecture, C++, Blueprint API and documentation"
engine: Unreal Engine 5
reel: https://youtu.be/sX3nIh14bYM
cover: /docs/Nested-Inventory-Architecture/img/T_NIA_Gallery1.png
tech: [C++, Blueprints, Replication, Gameplay Tags, Data Assets]
highlights:
  - No limit on nesting: every item can carry a full inventory of its own
  - Replicated through a single Inventory Manager component using Unreal's registered sub-object list
  - Every edit (Add, Discard, SetSlot, TransformSlots) can be overridden or replaced, in Blueprints or C++
  - Published on Fab with full documentation and a playable test build
links:
  reel: https://youtu.be/sX3nIh14bYM
  fab: https://www.fab.com/listings/320f157f-9241-47ee-9f32-63aaf744f509
  docs: /docs/nested-inventory-architecture
order: 20
---

## Overview

Nested Inventory Architecture (NIA) is an inventory framework for Unreal Engine. It started as the inventory for my own game and became a standalone plugin. Instead of a fixed list of slots, every item is an object that can hold an inventory of its own, so containers can live inside containers without any special cases.

## The challenge

Most inventory systems store items as plain structs in one flat array. That is quick to build, but it falls apart as soon as a game needs:

- **Containers inside containers:** a pouch in a backpack in a chest.
- **Per-item runtime state:** durability, wetness or ammo that changes during play.
- **Different kinds of slots:** a weapon slot that only accepts weapons, a grid that accepts anything.
- **Multiplayer:** all of the above has to replicate correctly, and only the server may change it.

I wanted one structure that handles all four, without forcing a particular editing style on the game that uses it.

## My approach

The key decision was to make items **objects instead of structs**. An object can use inheritance, hold runtime variables and own other objects, so nesting falls out of the design instead of being bolted on.

Each item is split into three parts:

- **Inventory Item:** the item itself, with no physical presence in the world. Any actor spawned from it can simply keep a reference to it.
- **Item Static Data:** a Data Asset with the values that never change at runtime: appearance, behaviour, and the template for the item's own inventory.
- **Item Payload:** the values that do change at runtime, plus the item's **Inventory System**, which is where nesting happens.

An Inventory System is made of **sections**, each identified by a Gameplay Tag. A section knows its grid size and which item types it accepts, so rules like "only rings go in ring slots" become a tag match instead of custom code.

![The inventory in action](/docs/Nested-Inventory-Architecture/img/T_NIA_Gallery1.png)

## Systems

### Looping item hierarchy

An Inventory Item holds a Payload, the Payload holds an Inventory System, and the Inventory System's sections hold more Inventory Items. Because the loop is part of the data model, the depth is unlimited and every level works the same way.

### Templates for starting inventories

Payload Template Data Assets describe what an item's inventory looks like when it is created: its sections, their grid sizes and the items already inside. Designers build these in the editor, and the plugin checks them for overlapping items and reports problems in the Output Log.

### Replication

All inventory objects share a base class managed by an **Inventory Manager Component** on the owning actor. The component owns the objects, registers them with Unreal's replicated sub-object list, and routes RPCs through itself. Item creation goes through server-side functions, so clients can never put the inventory into a state the server didn't approve.

### Open editing API

The plugin ships the common operations (Add, Discard, SetSlot, TransformSlots) but treats them as defaults. Each one can be overridden, or replaced with a game-specific operation, in Blueprints or C++, so the architecture adapts to the game rather than the other way round.

## Results

- Released on [Fab](https://www.fab.com/listings/320f157f-9241-47ee-9f32-63aaf744f509) with step-by-step [documentation](/docs/nested-inventory-architecture) and a playable test build.
- Used as the inventory of my own game, the project it was extracted from.

## What I learned

Choosing objects over structs cost some setup (outers, sub-object replication), and it paid for itself the moment nesting and per-item state were needed. Keeping the editing operations overridable from the start made the plugin useful to other developers, not only to my game.
