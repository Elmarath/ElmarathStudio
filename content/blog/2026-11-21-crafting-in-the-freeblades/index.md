---
title: "How crafting works in The Freeblades"
authors: [denizhan]
tags: [Gameplay Ability System, Common UI, Multiplayer, The Freeblades]
description: "A walk through one system I built for The Freeblades: from an anvil to a crafted item, using a Gameplay Ability, Common UI and Target Data to keep it right in multiplayer."
video: crafting.mp4
---

Crafting in [The Freeblades](/work/the-freeblades) touches most of the game's systems at once:
interaction, the UI, the Gameplay Ability System, animation and replication. That makes it a good
example of how I build gameplay features there, so here's how it works, from walking up to an anvil
to holding the finished item.

<!-- truncate -->

::video ./crafting.mp4 Crafting in The Freeblades: the crafting ability and its panel.

## From the anvil to the panel

The interaction logic already existed before crafting, so crafting starts like any other
interaction. When a player interacts with a crafting anvil, it triggers a crafting ability on the
player, `GA_Interact_Crafting`.

The ability pushes the crafting panel, a Common UI activatable widget, onto the screen and hands it
the recipes the player can make. Recipes are Data Assets. In the panel, players filter them by their
attributes, pick one and see what it needs.

Opening the panel uses the game's UI stacks: a Lyra-style root widget with stacks for the game, the
system and modal windows, which any system can reach. A function called *Push Panel to Stack* lets a
Gameplay Ability open a panel and wait for it to close, then end itself. Most of the game's panel-based
abilities work this way, not just crafting.

## Getting the request to the server

When the player confirms an item and a count, the request has to reach the server, which decides the
result, and the result has to stay in sync on the client. This was the challenging part, and it's
exactly what Gameplay Ability System **Target Data** is built for:

- The client sends the recipe and the count to the ability as Target Data and predicts the result.
- The server validates the request and corrects anything that went wrong.
- Other players see the crafting animation as well.

## Crafting over time

The crafting itself runs on a looping montage. Each time the montage sends a gameplay event, the
progress moves forward on a 0 to 1 scale. How far it moves depends on the character's skills, the tools
and the recipe's difficulty, so a skilled character with good tools crafts faster.

## Ending cleanly

When the progress is done, the ability ends gracefully: it finishes the montage, closes the panel and
hands over the new items. Because the panel and the ability are tied together through the UI stack,
closing one never leaves the other hanging.

## Why build it this way

- **One pattern for every panel:** abilities that open UI all push to a stack and listen for it to
  close, so new features follow the same shape.
- **Multiplayer for free, mostly:** Target Data, prediction and montage replication come from the
  Gameplay Ability System, so the custom work goes into the crafting rules, not the networking.
- **Designer-friendly:** recipes are Data Assets, so adding one doesn't need code.
