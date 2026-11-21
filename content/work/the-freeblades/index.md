---
title: The Freeblades
company: Tigerroll Studios
kind: Studio
role: Gameplay Programmer
location: United Kingdom · Remote
period: Dec 2025 – present
team: 5–10 people, remote
engine: Unreal Engine 5
summary: >-
  The Freeblades is a co-op action-adventure RPG combat game built in Unreal Engine 5 by Tigerroll
  Studios, a remote team of 5 to 10 people. As its gameplay programmer I lead the technical development
  and keep the game above 60 FPS on target hardware. I built every screen of its UI on Common UI, from the
  HUD to crafting, and the C++ framework under them. I also built the crafting, quest and dialogue systems,
  boss and magic abilities, inventory, in-game chat and saves, in C++ and Blueprints.
video: freeblades.mp4
tech: [C++, Blueprints, Common UI, Multiplayer, Gameplay Ability System, StateTree, UI materials, Perforce, Figma, Linear]
links:
  steam: https://store.steampowered.com/app/3983160/The_Freeblades/
  website: https://www.tigerrollstudios.co.uk/
stats:
  - { value: "60+", label: FPS on target hardware }
  - { value: "5–10", label: "people in the remote team" }
  - { value: "100s", label: of UI designs turned into in-game UI }
features:
  - title: Every screen, on Common UI
    text: >-
      The HUD, inventory, crafting, skills, quests, dialogue, chat, notifications and health bars, with the
      UI materials under them. A contract designer made textures and Figma designs; we iterated on them,
      and I built each panel in Common UI and made sure all of it works on a gamepad.
    media: interaction-ui.jpg
    tags: [Common UI, UI materials, Gamepad]
  - title: A UI framework in C++
    text: >-
      Our own input action widgets, base buttons and activatable widgets in C++, plus the functions Epic
      left out of Blueprints. A Lyra-style root layout holds Game, System and Modal stacks that any system
      can push a panel to.
    media: hud.jpg
    tags: [C++, Common UI, Architecture]
  - title: Boss and magic abilities
    text: >-
      The bosses' abilities and the magic abilities, built on the Gameplay Ability System, which handles
      their prediction and replication, plus the UI that responds when players use abilities.
    media: combat.jpg
    tags: [GAS, C++, Multiplayer]
  - title: Quests and dialogue
    text: >-
      A quest system I built, tested and connected to the game's other systems, and the dialogue: how
      conversations play out in the game, their panels, the choices and their style.
    media: ai-dialogue.jpg
    tags: [Quests, Dialogue, UI]
  - title: Inventory, chat and saves
    text: >-
      The systems behind what players carry, say and keep: inventory, in-game chat and save systems,
      in C++ and Blueprints.
    media: chat.jpg
    tags: [C++, Blueprints, Systems]
  - title: Developer tools and pipelines
    text: >-
      Tools and pipelines that help the team build and ship, including a clear path from hundreds of Figma
      designs to working in-game UI, while the game stays above 60 FPS on its target hardware.
    media: dungeon.jpg
    tags: [Tools, Figma, Performance]
quote:
  text: You have a technical mind and good mindset for creating game architecture.
  author: Blake Handley
  role: Technical Lead and founder, Tigerroll Studios
order: 1
---

## My part

As gameplay programmer I lead the game's technical development: its systems, developer tools and
pipelines, with the game held above 60 FPS on target hardware.

- **The whole UI.** Every screen, from the HUD and health bars to inventory, crafting, skills, quests,
  dialogue, chat and notifications, built on Common UI and playable on a gamepad. Under it sits a C++
  layer we built: our own input action widgets, buttons and activatable widgets, and a Lyra-style root
  with Game, System and Modal stacks, so any Gameplay Ability can open a panel and end when it closes.
- **Gameplay systems.** Crafting, quests, dialogue, inventory, in-game chat and saves, in C++ and
  Blueprints.
- **Abilities.** The bosses' and the magic abilities on the Gameplay Ability System, and the UI that
  responds to them.
- **Design to engine.** Figma workflows with our contract designer, turning hundreds of designs into
  working in-game UI.

## How we work

We're a remote team of 5 to 10 people spread around the world, with contractors joining for parts of
the project. We work in sprints with a daily stand-up, plan in Linear (Trello before that), keep the
project in Perforce, and work in English.

## Behind the scenes

::video ./working.mp4 A fast reel of me at work on The Freeblades: melee weapon traces, Blueprints and combat testing in Unreal Engine 5.
