---
sidebar_position: 1
---

# What are Actions For MAS?

You can think of the Actions as "Tasks" of the character's body. These tasks can come from various sources, such as character's controllers, enviroment, inventory interaction etc.

Every action has a goal in mind. But the animations for these goals can vary. It can vary to the character it self, or it's state.

To give an example: *Dodge* is an action. And it's goal is to move the character to the character's last input direction, so it won't get hit. The animation montage can vary if this character is a *monster*, or a *human*. Also if the character's is already in a dodge, it can *Roll Dodge*. It would not even get played if the owner character has no *stamina*. 

As you can see, goal is the same for the action, but animations differ to the circumstances. And it's the relevant **Decide Montage Data Asset's** responsibility to get the correct animation montage which we will get to it later.

## Action Data Asset Responsibilities

In every created child of **MAS-Action-Base** there are 2 functions that gives us the changes we need in order to update relevant attributes or call events. These are called **OnActionPhaseUpdated** and **OnActionGetsOverriden**.

For example they are good for: *Updating Warp Targets*, *Stamina Consumption*, *Movement State Updates*, *Weapon Trails* etc.

And also for reverting back the changes, when action gets finished at *New Action Phase = None* or in the function *OnActionGetsOverriden*.
