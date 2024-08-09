---
sidebar_position: 2
---

# Setup

There are only 2 assets that you need to use.

## Hit Trailer Component

This component is responsible for managing the created trails (Trails are UObjects), and giving them default values (which can be overridable when starting to trail.)

The base class of this component can be added both in c++ or blueprint. But I recommend you to create a child of this class `HitTrailer`.

![HowToCreateChildOfHitTrailer](./img/T_CreateChildOfHitTrailer.png)

After you create it in the details panel there is a option to select the default FPS of the trails. Don't worry they are overridable per trail. But it is good to have a good default value.

![HitTrailerDetails](./img/T_HitTrailerComponentDetails.png)

### On Hit Registered

After this you have a overridable event listed on your functions. Press the `override` button to see it. (Hover over over the functions tab and it will appear).

![OnHitRegistered](./img/T_InHitRegisterdFromSweepOverride.png)

This event will fire whenever a trail created from this component gets a valid hit result. Please note that the sweep result is just a one `MultiTraceByChannel Result`. In short it is "One single Box" of the Debugging visualisation.

![OnHitRegisteredResult](./img/T_OnHitRegisteredResult.png)

## Socket To Hit Type Data Asset

This [Data Asset](https://dev.epicgames.com/documentation/en-us/unreal-engine/data-assets-in-unreal-engine) type is responsible for getting all the sockets that is going to be used and map them to a relevant data. 

Create a instance of this data asset by Right Clicking your content browser -> Go To Miscellaneous -> Data Asset and find the `Socket To Hit Type`

![SocketToHitTypeCreate](./img/T_SocketToHitTypeCreatet.png)

### Socket To Hit Type Map

You need to populate this field by your skeletal mesh sockets.

* **Key [Name]** : The Skeletal Mesh Socket Initials. For example Skeletal Mesh Sockets has swing_01, swing_02,.... swing_09. By typing swing as a key, you map all the swing_.. sockets to key's value.
* **Value [FHitType]**
    * **Base Half Size**: The half size of the tracing box's edge.
    * **Hit Type**: The gameplay tag that is associated with the *Effect of the Hit*. Usefull for calculating damage, deciding particle and sounds etc.
    * **Debug Color**: The color for when debugging the trace.

![SocketToHitTypeInfo](./img/T_SocketToHitTypeInfo.png)

#### Project Settings

You can have a default Socket Tp Hit Type Map so that when you don't give a SocketToHitType while tracing, default asset can be used.

![Project Settings](./img/T_ProjectSettings.png)