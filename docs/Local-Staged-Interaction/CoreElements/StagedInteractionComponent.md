---
sidebar_position: 1
---

# Staged Interaction Component

The **Staged Interaction Component** is an [Actor Component](https://dev.epicgames.com/documentation/en-us/unreal-engine/components-in-unreal-engine) that can be added to any actor in your project. It is responsible for managing interaction stage data: determining which stages can be added, how they are triggered, and what happens when they are applied.

It also communicates directly with the `Local Staged Interaction Manager` subsystem.

As a designer, your role is to define:
- Which **stages** an actor can have
- The **conditions** under which those stages apply
- The **executions** that run when a stage is triggered

---

## Key Events

### 🔄 Stage Events

These events fire when interaction stages are successfully added or removed from the component:

- `On Interaction Stage Added`
- `On Interaction Stage Removed`

---

### ⚙️ Virtual Execution Events

Virtual Executions provide an easy way to trigger logic without writing custom `Interaction Execution` subclasses. You simply:

1. Add a **Virtual Execution** to the execution list.
2. Set a custom `FName` identifier.
3. Respond to the following events in your actor:

- `On Virtual Execution Started`
- `On Virtual Execution End`

These events allow you to execute custom logic directly in the owning actor, based on the Virtual Execution name.

---

## 🧩 Blueprint Support

The `Staged Interaction Component` is fully **Blueprintable**. You can create child components that contain project-specific features or logic and reuse them across multiple actors.

---

## 🔗 Multiplayer Considerations

While this system is designed to be **local-only**, you can extend it for networked interactions. Keep in mind:

- All events are fired **locally**, from the perspective of the local player.
- You can add another component or a child of this one to handle multiplayer logic—such as:
  - Counting how many players are interacting with an object
  - Controlling access to interactions (e.g., only one player can open a chest at a time)
  - Requiring multiple players to activate something (e.g., multi-user switches or gates)

---

With the right setup, the Staged Interaction Component can be the foundation of both single-player and multiplayer interaction systems.