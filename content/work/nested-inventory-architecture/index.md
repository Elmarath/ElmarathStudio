---
title: Nested Inventory Architecture
summary: >-
  Nested Inventory Architecture is a replicated, object-based inventory framework for Unreal Engine,
  where any item can hold an inventory of its own: pouches in backpacks in chests, attachments inside
  weapons. It started as the inventory for my own game and became a standalone plugin on Fab. Items are
  objects instead of structs, so nesting and per-item runtime state come from the design rather than
  special cases, and every editing operation can be overridden in Blueprints or C++.
kind: Plugin
role: "Solo developer: architecture, C++, Blueprint API and documentation"
engine: Unreal Engine 5
reel: https://youtu.be/sX3nIh14bYM
cover: /docs/Nested-Inventory-Architecture/img/T_NIA_Gallery1.png
team: Solo
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
stats:
  - { value: "∞", label: "levels of nesting, every level working the same way" }
  - { value: "1", label: component that owns and replicates the whole inventory }
  - { value: "4", label: "editing operations, each one overridable in Blueprints or C++" }
features:
  - title: Looping item hierarchy
    text: >-
      An Inventory Item holds a Payload, the Payload holds an Inventory System, and the Inventory
      System's sections hold more Inventory Items. The loop is part of the data model, so depth is
      unlimited and every level behaves the same.
    tags: [Data model, C++]
  - title: Templates for starting inventories
    text: >-
      Payload Template Data Assets describe an item's inventory when it's created: its sections, their
      grid sizes and the items already inside. The plugin checks them for overlaps and reports problems
      in the Output Log.
    tags: [Data Assets, Tools]
  - title: Server-authoritative replication
    text: >-
      Every inventory object is owned by an Inventory Manager Component, registered with Unreal's
      replicated sub-object list. Changes go through server-side functions, so clients can't put the
      inventory into a state the server didn't approve.
    tags: [Replication, Multiplayer]
  - title: An open editing API
    text: >-
      Add, Discard, SetSlot and TransformSlots ship as defaults. Each can be overridden or replaced with
      a game-specific operation, so the architecture adapts to the game rather than the other way round.
    tags: [API design, Blueprints]
order: 5
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

## Results

- Released on [Fab](https://www.fab.com/listings/320f157f-9241-47ee-9f32-63aaf744f509) with step-by-step [documentation](/docs/nested-inventory-architecture) and a playable test build.
- Used as the inventory of my own game, the project it was extracted from.

## What I learned

Choosing objects over structs cost some setup (outers, sub-object replication), and it paid for itself the moment nesting and per-item state were needed. Keeping the editing operations overridable from the start made the plugin useful to other developers, not only to my game.
