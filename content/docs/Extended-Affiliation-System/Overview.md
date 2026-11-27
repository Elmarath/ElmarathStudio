---
sidebar_position: 1
---

# Overview

::plugin-links

<!-- TODO: add the showcase video (AI behaviour and the debug view) here, like the other plugins' Overview pages:

## Video Overview

::youtube <link>

or, for a short looping clip next to this file: cd site && npm run video -- <export> ../content/docs/Extended-Affiliation-System
::video ./<name>.mp4 AI teams fighting, with the debug view on
-->

**Extended Affiliation System** decides who is on whose side in your game.

Every faction or team is a **data asset**, an *Affiliation Group*. Each group decides how it sees the other groups: **Friendly**, **Neutral** or **Hostile**. Any actor can join a group, and any Blueprint can ask *"how does this actor see that one?"*.

It is made for **Blueprint-only projects** and works in **single player and multiplayer**.

---

### ⭐ Key Benefits

- **No hard-coded teams:** factions and their relationships are assets that designers can edit.
- **Ready-made rules:** decide relationships by Gameplay Tags, by a list of groups, by "same team", or write your own rule in Blueprint.
- **Multiplayer teams:** groups are set by the server and replicated to every player.
- **Change sides at runtime:** a bribed guard, a mind-controlled monster, a player switching teams.
- **See it before you play:** every group asset shows how it and every other group see each other.
- **Debug view:** one console command shows every actor's group above its head.

---

### 🎮 Typical Use Cases

- **Teams in multiplayer games:** Red vs Blue, squads, free-for-all.
- **AI factions:** who attacks whom, who ignores whom.
- **Friendly fire:** only damage actors that are *Hostile*.
- **Targeting:** filter the actors around the player down to enemies.
- **Neutral things:** wildlife, props and interactables that no one fights.

---

## Key Concepts

| Concept | What it is |
| --- | --- |
| **Affiliation Group** | A data asset for one faction or team, for example *AG_Team_Red*. |
| **Attitude** | How one group sees another: Friendly, Neutral or Hostile. |
| **Decider** | The rule inside a group that picks its attitude towards other groups. |
| **Group Member** | A component that puts an actor in a group. |
| **Group Member Manager** | A component for controllers: the player or the AI owns the group, and its pawn gets it. |

:::note Attitudes go one way
Red's attitude towards Blue comes from Red's decider, and Blue's towards Red from Blue's. They can differ: wolves can hate villagers while villagers ignore wolves.
:::

Let's set it up!
