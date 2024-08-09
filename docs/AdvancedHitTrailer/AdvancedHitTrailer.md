---
sidebar_position: 1
---

# Advanced Hit Trailer Overview

The plugin aims to have a modular way to get multiple hit results from the given skeletal mesh sockets in a time period that can be activated or deactivated with handles.

## Main Features 


 * Multiple tracing system with a handle the control it.
 * Additional hit results from the trail. Such as hit type, speed, hit socket, trail payload UObject etc.
 * Customizable trace source data assets. To have appropiate hit sockets and hit types per trail.
 * Project settings for making using default data assets when trailing.
 * Debugging visualisation.


![Advanced Hit Trailer Example](./img/T_AdvancedHitTrailerExample.png)

:::note
    The Hit Results of the Trail is the same as `MultiBoxTracingByChannel` from the Default Unreal Engine Blueprint Node.
    This means:
    * A Trail can hit an actor once.
    * Trace channel must overlap with the actors (not block).
    * A trail can hit multiple Actors at once.

    But you can always stop the trail when a actor gets hit. So you have the best of the both worlds.
:::

Though it is a very simple tool to use, there are few subjects we need to cover to use this tool fully.