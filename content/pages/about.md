---
title: About me
description: Gameplay programmer and computer engineer. I build dependable Unreal Engine 5 systems and tools that help teams build and ship efficiently.
---

I'm Denizhan Toprak, a gameplay programmer with a computer engineering background, based in İzmir, Türkiye. I focus on dependable systems that help teams build and ship efficiently: shaping technical workflows, creating and extending development tools, and balancing performance with maintainability. I've worked with game studios and software companies, remotely and in the office.

What I enjoy most is creating tools and robust system designs that make projects more enjoyable, efficient and scalable to work on. Every plugin on this site started that way.

## Experience

### Gameplay Programmer

[Tigerroll Studios](https://www.tigerrollstudios.co.uk/) · United Kingdom, remote · Dec 2025 – present

- Designing and implementing core gameplay systems for [The Freeblades](https://store.steampowered.com/app/3983160/The_Freeblades/), a co-op action-adventure RPG combat game in Unreal Engine 5, in a remote studio of 5 to 10 people.
- Leading the game's technical development: developer tools, pipelines and gameplay systems, while keeping it above 60 FPS on target hardware.
- Own gameplay AI (built with StateTree), the quest system, dialogue (how conversations play out, their panels and choices), crafting, boss and magic abilities, inventory, in-game chat, save systems and more, in C++ and Blueprints.
- Built the game's UI/UX on Unreal Engine's Common UI framework and UI materials, extending it into a cross-platform, gamepad-friendly interface architecture. The team works in Perforce.
- Coordinate design and engineering through organised Figma workflows, with clear pipelines for turning hundreds of UI designs into in-game UI.

### C++ Developer

[Archinord Software](https://www.archinord.com/en) · Türkiye, office · Jul 2024 – Jul 2025

- Led the development of multiple [architectural visualisation projects](https://archinord.com/moduller/sunum) in Unreal Engine 5 and AWS, as part of a three-person team, helping the studio partner with 20+ construction companies within six months of its launch.
- Architected the content delivery behind them: one core Unreal Engine project, with each of the 20+ clients' projects as its own Game Feature plugin, hosted on AWS S3 and delivered with an extended ChunkDownloader. Clients signed in with their company email, saw only their own projects, and got the latest version when they opened one, so their frequent changes (interiors especially) reached their customers sooner, and every improvement to the core reached all clients at once.
- Wrote OnlineAttributeSheet, a plugin whose refreshers keep values in sync from the company website (or Google Sheets), in game and in the editor. Stored as `FName`s and converted on demand into Gameplay Tags, prices or levels through custom Blueprint nodes, they drove availability, pricing, each apartment's interior for virtual tours, sign-in and the points of interest around each development.
- Worked with Game Features, World Partition, Mass, Cesium, MetaHumans, Common UI, UI materials and Plastic SCM.

### Lead Developer, indie game project

Self-directed · Dec 2023 – present

- Developing [Thrall Guard](/blog/how-i-create-my-game-thrall-guard), a top-down co-op medieval slasher, in Unreal Engine 5.
- Created and published [Unreal Engine plugins](https://www.fab.com/sellers/Elmarath) for the community, with over 4,500 sales. They're documented [here](/docs).
- Implementing and extending Unreal Engine frameworks: the Gameplay Ability System (GAS), Common UI, MVVM, Mover 2.0, Gameplay Cameras and StateTree.
- Creating custom shaders, UI materials, animations, VFX, cinematics and level designs.

### Software Developer

[Retter Business Services](https://www.retter.io/) · Türkiye, remote · Jul 2021 – Jul 2023

- Developed retail backend projects from the start, documenting and addressing issues, including [Pınaronline](https://www.pinaronline.com), [Jotun Usta Fırçalar](https://play.google.com/store/apps/details?id=com.jotun.jotunustafircalar), [Koçailem](https://www.kocailem.com) and [Unishop](https://www.unishopturkiye.com).
- Built reusable n8n backend testing workflows for 20+ customer projects, improving stability and cutting developer testing time by 80%.
- Wrote the first version of the [Retter platform's developer documentation](https://docs.retter.io), covering its in-house web development tools.

## Plugins

Each of these began as a system my own projects needed. The docs cover setup and usage in detail.

- **[Staged Interaction System](/docs/Staged-Interaction-System):** a stage-based approach to gameplay interactions, where each interaction state is handled independently and modularly in multiplayer games using State Trees.
- **[Ability Queue Task System](/docs/Ability-Queue-Task-System):** builds on Epic's Gameplay Ability System with a non-destructive, customisable input queue for fluid action transitions.
- **[Nested Inventory Architecture](/docs/Nested-Inventory-Architecture):** an object-based, replicated grid inventory where any item can hold other items as a container, built on Data Registry, Gameplay Tags and instanced data fragments.
- **[Easy Skeletal Mesh Merge Async](/docs/Easy-Skeletal-Mesh-Merge-Async):** merges skeletal meshes into one at runtime in networked games, to optimise players, NPCs and weapons.
- **[Easy Ability Set System](/docs/Easy-Ability-Set-System):** grants and clears gameplay abilities in bulk, with automatic input binding and effect sets.
- **[Dynamic Input System](/docs/Dynamic-Input-System):** binds, modifies and manages input mappings at runtime based on game context, and shows players the matching prompts (for example, LMB to Attack).

## Skills

| Area | Tools and technologies |
| --- | --- |
| Engine | Unreal Engine 5, Blueprints, Gameplay Ability System, StateTree, Common UI, MVVM, Mover 2.0, Gameplay Cameras, Game Features, World Partition, Mass, MetaHumans, Cesium |
| Specialities | Gameplay systems, network replication, software architecture, tools, UI/UX, UI materials, shaders and VFX |
| Programming | C++, C#, Java, Python, JavaScript and Node.js, OOP |
| Art and animation | Blender, Cascadeur |
| Cloud and source control | AWS, Git, Perforce, Plastic SCM |
| Workflow | Project management, Jira, Trello, Figma, Visual Studio, Rider, VS Code, Agile, remote work |

## Education

### Bachelor of Computer Engineering

Marmara University · Sep 2019 – Jul 2023

I founded and chaired the **Marmara University Game Development** club, organising game jams, workshops and events for students getting into game development.

## Languages

English and Turkish.
