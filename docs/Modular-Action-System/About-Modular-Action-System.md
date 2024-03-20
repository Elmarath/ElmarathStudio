---
sidebar_position: 1
---

# About Modular Action System (MAS)

**Modular Action System** (in short **MAS**) will allow you to create actions inside **[Data Assets](https://docs.unrealengine.com/5.2/en-US/data-assets-in-unreal-engine/)**. Default Data Asset can be overriden to add your logic inside it. After you populate the instances of your created actions, you can input these actions to your **Characters** in your  **[Controllers](https://docs.unrealengine.com/5.2/en-US/data-assets-in-unreal-engine/)** and the actor component **Action Manager** will handle the rest.

### Youtube Video Tutorial
Click the image to watch the tutorial.

[![Youtube Video Tutorial](https://img.youtube.com/vi/-XQRBBMxkSM/0.jpg)](https://www.youtube.com/watch?v=-XQRBBMxkSM)

## What You Can Do With MAS 

- **Action Buffers** is integrated in the **Action Component**. So input actions will be added to the queue to be played when the higher priority action finishes its prior phase.
- **Action Chains** allows you to input chain of actions to the component. Even the single actions are converted to a single chain. This system will allow you to give bunch of actions related together, and each action will be independent to be overriden.
(For example 0-GetArrow, 1-DrawBow 2-ReleaseBow)
- **Ability System** can be achieved with checking if the character can perform this action by looking the character's current attributes.
- **Looping Actions** can also be done by creating looping montage. As long as the montage is looping action and its phase remains the same. (For example: Blocking, DrawingBow, Falling, Aiming).
- **Online Replicated Actions** is integrated with the system. Montages will be played, action phases will be updated in both client and the server.
- **Combo** systems for your combat can be easly achived.
- **Gameplay Events** can be triggered inside actions. (For example: *StartInteraction*, *StartWeaponTrail* etc.)
