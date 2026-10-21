---
sidebar_position: 1
---


# Overview of Ability Queue Task System

::plugin-links

## Video Overview

Watch this comprehensive tutorial to see **Ability Queue Task System** in action:

::youtube dR8Dbne-xe4

*This video demonstrates the complete workflow from setup to implementation.*

### Description

**Ability Queue Task System** is a powerful Unreal Engine plugin built on top of Epic's Gameplay Ability System (GAS). It enables abilities to play one after another based on how they are activated: inputs, gameplay events, class-based triggers, and more.

By assigning abilities to states, each with its own priority, the system lets you create highly modular ability behaviors:

- **Higher-priority abilities can interrupt lower-priority ones**
- **Ability priority can change dynamically by switching states**
- **Abilities naturally chain into fluid sequences**

Best of all, the plugin is non-destructive: it works with your existing ability classes. No custom GAS classes required. Just add the "Add to Queue" task to your abilities and the system handles the rest.

---

## ⭐ Key Benefits

- **Queue-based action ability playback** for smooth transitions
- **Fully compatible** with standard Gameplay Ability System
- **Priority-per-state logic** for dynamic control
- **Abilities, not inputs, enter the queue** → context-sensitive results
- **Network tested** and ready for multiplayer
- **Lightweight, modular, and easy to integrate**
- **Debug tools included** to visualize queues and states

---

## 🎮 Typical Use Cases

- **Souls-Like fluid action transitions** - Chain abilities seamlessly for responsive combat
- **No input loss for Players or AI** - If the current ability doesn't allow the input ability, the input ability will try to activate itself inside the queue window, making player inputs much more responsive
- **Ability Combos** - Create complex combo systems with priority-based activation
- **AI input handling** - AI can press inputs to activate/queue their abilities, just like how players do

---

## 🔗 Dependencies

This plugin requires the [GameplayAbilities](https://dev.epicgames.com/documentation/en-us/unreal-engine/gameplay-ability-system-for-unreal-engine) module to be enabled in your project.
