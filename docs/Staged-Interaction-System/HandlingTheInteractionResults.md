---
sidebar_position: 4
---

# Handing the Interaction Results

Now that we know how we add our interaction stages to the interactables, we now ready to use the runtime stage information to effect our game world.

As said in the **Setup**, you can use the *On Player Gameplay Interaction Stage Changed* or *On Player Indication Indication Changed* events on the *Stage Gameplay Interactable* to handle these interactions in blueprints. If so you can create a nested if-else conditions to handle each case of the interaction. 

Such as: 

- Is Player Near?

- Is Player Looking at the Actor?

- Is Someone else interacting?

This is completely achievable using the delegates and the current states of the *gameplay* and *indication* stages. But if your interaction system is a complex or multiplayer, this can be hard to manage.


*Data Structure of Stages that are holded per interactor.*
![DataStructureOfInteractionStages](./img/T_StageInteractionValueTypes.png)

Instead of using if else statements, I recommend you to use [State Trees](https://dev.epicgames.com/documentation/en-us/unreal-engine/state-tree-in-unreal-engine) to handle the stage updates. State trees can be added to any Actor and has a clear view of nested conditions. Which is perfect for this framework.

If you want to see a working example of implementing a state tree for stage interaction system, please check out this [Overview Video](https://youtu.be/N_uTlWtp7rg?si=3kOuyNfDsfCJCaPx) of this plugin.