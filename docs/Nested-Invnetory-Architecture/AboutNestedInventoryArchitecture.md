---
sidebar_position: 1
---

# About Nested Inventory Architecture

**Nested Inventory Architecture** (abbreviated as **NIA**) will allow your players to create and interact with inventories intuitively and easily with the help of *Nested Inventory*, *Object Based*, *Section Based* approach with customizable architecture!

**Docs: [Documentation](https://elmarathstudio.netlify.app/)**
:::note
    NIA -as the name suggest- is an architecture, it allows you to build your inventory based on a well designed structre but **it doesn't restrict the way you edit them**. There are some basic functions such as: *Add*, *TransformSlots*, *Discard*, *SetSlot*" etc. But you can **override** them, or **create new editing methods from scratch**!
:::

## This System Gives You:

 - **Nested Inventory System** will allow items to hold other inventories! Backpacks within packpacks, weapon attachments inside weapons... Everything is possible!

 - **Object Based Architecture** makes possible to make use of inheritance for primitive item types and hold runtime variables for items. Everthing a object can do.

 - **[Data Asset](https://dev.epicgames.com/documentation/en-us/unreal-engine/data-assets-in-unreal-engine) Use For Base Info** allows items to hold customized variables types per class with the help of inheritance and many other advantages of using data assets.

 - **Sections as [GameplayTags](https://docs.unrealengine.com/4.27/en-US/ProgrammingAndScripting/Tags/)** used for Inventories the hold sections with different types. Allowing item transform in a much more intiuative manner. Allowing logics like: *If item tag and section tag matches* etc.
- **Customizable Inventory Editing** is always avalible by overriding the releted methods, blueprint or c++!


![NIA_Gallery](./img/T_NIA_Gallery1.png)
