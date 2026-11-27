---
sidebar_position: 5
---

# Reference

Everything the plugin gives you in the editor and in Blueprints, in one place: assets, components, nodes, events and console commands. Names are shown as they appear in the editor.

## Assets

### Affiliation Group Data

A data asset: one faction. See [Setup](./Setup.md#2-create-groups).

| Property | Description |
| --- | --- |
| **Group Name** | The group's name. Shown by the debugger. |
| **Affiliation Group Tags** | The group's `Affiliation.*` tags. |
| **Affiliation Decider** | How this group sees other groups. Empty means Neutral towards everyone. |
| **Metadata Map** *(advanced)* | Named extra data for your UI. |
| **Generic Team ID** *(advanced)* | A team number for projects that also use Unreal's Generic Team system. The plugin only stores it. |
| **Debug Color** *(editor)* | Color in the debug view and the Affiliation Preview. |
| **Preview Priority** *(editor)* | Higher numbers are listed first in the Affiliation Preview. |

| Node | Description |
| --- | --- |
| **Get Affiliation Attitude Towards Group** | This group's attitude towards another group. A *Universal* decider on the other group overrides this group's decider; two Universal groups take the friendlier attitude. Returns Neutral if the other group is empty or this group has no decider. |
| **Get Metadata By Name** | The metadata with that name, or nothing. |
| **Get Metadata By Class** | The first metadata of that class, or nothing. The output already has the class you picked. |
| **Get Metadata By Name And Class** | The metadata with that name, if it is of that class. |

### Deciders

Picked in a group's **Affiliation Decider** dropdown. Every decider has a **Default Attitude**, used when none of its rules apply.

| Decider | Settings | Answers with |
| --- | --- | --- |
| **By Gameplay Tag (Does Other Group Match Query?)** | **Attitude Tag Queries**: one tag query per attitude | The first query that matches the other group's tags, checked as Hostile, Friendly, Neutral (empty queries are skipped), else *Default Attitude*. |
| **By Explicit Reference** | **Attitude Groups**: one list of groups per attitude | The attitude whose list holds the other group (Friendly, Neutral, Hostile order), else *Default Attitude*. Data validation reports a group listed twice. |
| **By Same Team** | **Same Team Attitude** (Friendly by default) | *Same Team Attitude* towards its own group, else *Default Attitude* (Hostile by default). |
| **Static** | — | Always *Default Attitude*. |
| **Universal (Both Ways)** | — | Friendly towards its own group, *Default Attitude* towards others, and overrides how the other groups see it. |

To make your own, create a Blueprint child of **Affiliation Decider Towards Group** (or of any decider above) and override **Get Affiliation Towards Group** (*From Group*, *To Group* → attitude). See [Writing Your Own Decider](./Using-The-System.md#writing-your-own-decider).

### Metadata

Added to a group's **Metadata Map**. Make your own with a Blueprint child of **Affiliation Metadata**.

| Metadata | Property |
| --- | --- |
| **Color** | **Color** |
| **Multiline Text** | **Text** (multiline) |
| **Texture Material Interface** | **Material Interface**: a texture or a material |

---

## Components

### Stimuli Source Affiliation Group Member

Goes on any actor and makes it a member of a group. Replicated. It is also an *AI Perception Stimuli Source*, with all of that component's settings.

| Property, node or event | Description |
| --- | --- |
| **Default Affiliation Group** | Set on *Begin Play* (server), unless the owner is a pawn whose controller has a *Group Member Manager On Possessed Pawn*: then the controller's group is used. |
| **Set Current Affiliation Group** | *Server only.* Sets and replicates the group. Does nothing if it is already the group. Don't use it on pawns managed by a controller. |
| **Get Current Affiliation Group** | The current group. |
| **On Affiliation Group Changed** | *Event (server and clients).* Fires with the new group. |
| **BP On Affiliation Group Changed** | Overridable event in a Blueprint child, same timing. |

### Group Member Manager On Possessed Pawn

Goes on a Player or AI Controller. The controller owns the group and gives it to the pawn it possesses. Replicated. See [Setup](./Setup.md#4-give-players-and-ai-a-group).

| Property, node or event | Description |
| --- | --- |
| **Default Affiliation Group On Possessed Pawn** | The controller's group on *Begin Play*. |
| **Apply Group On Possession Change** | When checked (default), every pawn the controller possesses later gets its group. Can be changed at runtime. |
| **Set Current Affiliation Group On Possessed Pawn** | *Server only.* Stores the group and gives it to the possessed pawn. Replicates and fires the event only when the group changes. |
| **Get Current Affiliation Group On Possessed Pawn** | The controller's current group. |
| **Apply Affiliation Group To Pawn** | Overridable function in a Blueprint child. Gives the group to a pawn; by default it sets it on the pawn's *Stimuli Source Affiliation Group Member*. Override it if your pawns keep their group elsewhere. |
| **On Affiliation Data On Possessed Pawn Changed** | *Event (server and clients).* Fires with the new group. |
| **BP On Affiliation Group On Possessed Pawn Changed** | Overridable event in a Blueprint child, same timing. |

---

## Interface

### Extended Affiliation Actor Interface

Add it in *Class Settings → Implemented Interfaces* of an actor.

| Function | Description |
| --- | --- |
| **Get Affiliation Group Data** | Return the actor's group. When an actor implements it, the plugin's nodes use it instead of looking for the component. |

---

## Nodes

### Extended Affiliation Helper

Pure nodes under *Affiliation System*, usable from any Blueprint.

| Node | Returns |
| --- | --- |
| **Get Affiliation Group Data From Actor** | The actor's group, and *true* if the actor implements the interface or has the component. The group can still be empty. |
| **Get Affiliation Attitude Towards Actor** | How *From Actor* sees *Towards Actor*, and *true* if both are members and *From Actor* has a group. |
| **Get Affiliation Attitude Towards Actor By Group** | How a group sees an actor, and *true* if the group is set and the actor is a member. |
| **Get Affiliation Query Matching Actors** | The actors whose group's tags match a tag query. |
| **Get Affiliation Query Matching Actors Batch** | One result per tag query, in the same order, each holding its query and the actors that match it. |
| **Get Actors By Affiliation Attitude** | The actors that *Reference Actor* sees with the given attitude. |
| **Get Actors By Affiliation Attitude Batch** | One result per attitude that occurs, each holding the attitude and its actors. |

Actors that are not members are skipped.

---

## Console Commands, Logs and Tags

| Name | Description |
| --- | --- |
| `AffiliationSystem.EnableDebugMode 1` / `0` | Turns the runtime debug view on or off. Debug and Development builds only. See [Debugging at Runtime](./Editor-Tools-And-Debugging.md#debug-view). |
| `Log LogExtendedAffiliationSystem VeryVerbose` | Shows the plugin's detailed log messages. |
| `Affiliation` | The root Gameplay Tag. Tag fields in the plugin only show tags under it. |
