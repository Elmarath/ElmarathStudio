---
id: EasyAbilitySetSystemStartup
title: Easy Ability Set Startup
sidebar_position: 1
---

# Easy Ability Set System for Gameplay Ability System

The **Easy Ability Set System** is a [Lyra](https://dev.epicgames.com/documentation/en-us/unreal-engine/lyra-sample-game-in-unreal-engine?application_version=5.5)-inspired, lightweight plugin that extends Unreal Engine’s [**Gameplay Ability System (GAS)**](https://dev.epicgames.com/documentation/en-us/unreal-engine/gameplay-ability-system-for-unreal-engine). It lets you easily define, grant, clear, and manage groups of abilities at runtime—no more assigning abilities one by one!

:::note
**New to GAS?**  
The Gameplay Ability System is powerful but advanced. If you’re new, check out this [**GAS Tutorial**](https://dev.epicgames.com/community/learning/tutorials/8Xn9/unreal-engine-epic-for-indies-your-first-60-minutes-with-gameplay-ability-system).
:::

With this plugin, you can bundle abilities into **Ability Sets** and apply them to any actor using the **Ability System Set Manager**—all with a designer-friendly workflow.

---

## 🔹 What Does This Plugin Provide?

- **Ability Sets:**  
  Create groups of abilities and grant or remove them at runtime using the **Ability System Set Manager** component.

- **Input Bindings:**  
  Use Data Assets to manage input bindings for both players and NPCs. Add or remove bindings at runtime—no code required!

- **Data-Oriented Design:**  
  Designers can create modular gameplay by mixing and matching Ability Sets and input mappings for different game modes or features.

- **Networking Support:**  
  All features work seamlessly in multiplayer.

---

## 🔹 Getting Started

### 1. Enable the Plugin
- Download or install the plugin.
- In Unreal Engine, go to `Edit → Plugins`.
- Enable **Easy Ability Set System** and restart the editor.

### 2. Create an Ability Set
- Right-click in the Content Browser → `Miscellaneous → Data Asset → Easy Ability Set`.
- Add your abilities and input tags.

### 3. Create Ability to Input Mappings
- Right-click in the Content Browser → `Miscellaneous → Data Asset → Easy Ability To Input Mapping`.
- Add your **Input Actions** and tags.  
  *Trigger types* let you specify if the input fires on press or release.

### 4. Add the Ability Set Manager Component
- Open your Blueprint (usually your Pawn or Player State) that has the Ability System Component.
- Add the **EasyAbilitySetComponent**.
- Optionally, fill the **Initialized Ability Sets** field to grant sets automatically on Begin Play.

### 5. Grant or Remove Ability Sets
- **Blueprint:**  
  - Use **Give Ability Set** to grant all abilities/effects from a set.
  - Use **Remove Ability Set** to remove everything previously granted.
- **C++:**
  ```cpp
  AbilitySystemSetManager->GiveAbilitySet(MyAbilitySet);
  AbilitySystemSetManager->ClearAbilitySet(MyAbilitySet);
  ```

### 6. Add the Ability System Input Controller (for Players)
- Open your Player Controller Blueprint.
- Add the **Ability System Input Controller** component.
- Optionally, fill:
  - **Init Ability Input Mappings** with your input mapping assets.
  - **Ability Sets to Grant on Possessed Pawn** with your Ability Sets (these will be granted when the controller possesses a pawn).

### 7. Manage Ability Input Mappings at Runtime
- **Blueprint:**  
  - Use **Add Ability Input Mappings** to add mappings.
  - Use **Remove Ability Input Mappings** to remove mappings.
  - Use **Clear Ability Input Mappings** to clear all mappings.
- **C++:**
  ```cpp
  AbilitySystemInputController->AddAbilityInputMappings(MyInputMappingArr);
  AbilitySystemInputController->RemoveAbilityInputMappings(MyInputMappingArr);
  AbilitySystemSetManager->ClearAbilityInputMappings();
  ```

---

And that’s it!  
You now have a modular, designer-friendly way to manage abilities and input in your project.  
Explore the plugin for more advanced features and customization!