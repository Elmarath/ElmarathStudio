---
title: Fab Vendor
company: Elmarath
kind: Fab vendor
role: Plugin developer and publisher
team: Solo
engine: Unreal Engine 5
video: interaction.mp4
summary: >-
  As Elmarath, I publish Unreal Engine plugins on Fab, Epic's marketplace, with over 4,500 sales so far.
  Each one began as a system my own game needed: interactions, hit detection, abilities, inventories,
  input and modular characters. I design them as reusable C++ frameworks with full Blueprint APIs,
  build them to work in multiplayer, and document every one on this site. Six of my plugins are also
  free and open source on GitHub.
tech: [C++, Gameplay Ability System, Replication, Blueprints, StateTree, Gameplay Tags, Data Assets, Async loading]
links:
  plugins: https://www.fab.com/sellers/Elmarath
  docs: /docs
  github: https://github.com/Elmarath
stats:
  - { value: "4,500+", label: plugin sales on Fab }
  - { value: "8", label: "plugins, each with full documentation on this site" }
  - { value: "6", label: open-source plugins on GitHub }
features:
  - title: Staged Interaction System
    text: >-
      Complex player interactions split into stages, each handled on its own and in multiplayer, using
      StateTree, events and Gameplay Tags. [Docs](/docs/Staged-Interaction-System) ·
      [Fab](https://www.fab.com/listings/ea6cda8e-25b1-434e-a9ab-1c2bbaa5fe67)
    media: /docs/Staged-Interaction-System/thumbnail.png
    tags: [StateTree, Gameplay Tags, Multiplayer]
  - title: Easy Trace-Trail System
    text: >-
      Continuous hit trails for weapons and abilities, run by a World Subsystem, with results you can
      control and extend. [Docs](/docs/Easy-Trace-Trail-System) ·
      [Fab](https://www.fab.com/listings/86d9af14-9ab3-4c47-83b2-96eb6a4b5957)
    media: trace-trail.mp4
    tags: [Combat, C++, Subsystems]
  - title: Easy Skeletal Mesh Merge Async
    text: >-
      Modular characters merged into one mesh at runtime: parts load in the background, a newer request
      cancels the old one, and the result replicates. [Docs](/docs/Easy-Skeletal-Mesh-Merge-Async) ·
      [Fab](https://www.fab.com/listings/616906a0-c73d-4e7a-9002-866a6d9751d5) ·
      [GitHub](https://github.com/Elmarath/EasySkeletalMeshMergeAsync)
    media: merge.mp4
    tags: [Async loading, Replication, Optimisation]
  - title: Nested Inventory Architecture
    text: >-
      A replicated, object-based grid inventory where any item can hold an inventory of its own, built
      on Data Registry, Gameplay Tags and instanced data. [Docs](/docs/Nested-Inventory-Architecture) ·
      [Fab](https://www.fab.com/listings/320f157f-9241-47ee-9f32-63aaf744f509)
    media: /docs/Nested-Inventory-Architecture/thumbnail.png
    tags: [Replication, Data model, C++]
  - title: Ability Queue Task System
    text: >-
      An extension of the Gameplay Ability System that queues abilities and activates them by priority,
      for fluid combos and action transitions. [Docs](/docs/Ability-Queue-Task-System) ·
      [Fab](https://www.fab.com/listings/554398ff-338b-43da-bf43-b081ef166b92)
    media: /docs/Ability-Queue-Task-System/thumbnail.png
    tags: [GAS, Gameplay Tasks]
  - title: Modular Action System
    text: >-
      A data-driven, network-ready action system: actions as Data Assets, with action chains, buffers,
      looping actions and combos, replicated between server and clients.
      [Docs](/docs/Modular-Action-System) · [Fab](https://www.fab.com/listings/6ef3ecaa-1a2f-4056-a209-cf228df40c3f)
    media: /docs/Modular-Action-System/thumbnail.png
    tags: [Data Assets, Animation, Replication]
  - title: Easy Ability Set System
    text: >-
      Grants and clears Gameplay Abilities in bulk from Ability Set Data Assets, with automatic input
      binding and effect sets. [Docs](/docs/Easy-Ability-Set-System)
    media: /docs/Easy-Ability-Set-System/thumbnail.png
    tags: [GAS, Input]
  - title: Dynamic Input System
    text: >-
      Binds, changes and manages input mappings at runtime based on game context, and shows players the
      matching prompts. [Docs](/docs/Dynamic-Input-System) ·
      [Fab](https://www.fab.com/listings/cdf2ad8e-b9b7-4b4e-87bb-fdcfbe3c3b2b) ·
      [GitHub](https://github.com/Elmarath/DynamicInputSystem)
    media: /docs/Dynamic-Input-System/thumbnail.png
    tags: [Input, Blueprints]
  - title: Open source on GitHub
    text: >-
      Six plugins are free and open source:
      [Easy Skeletal Mesh Merge Async](https://github.com/Elmarath/EasySkeletalMeshMergeAsync),
      [Dynamic Input System](https://github.com/Elmarath/DynamicInputSystem),
      [Easy User Interface Management](https://github.com/Elmarath/EasyUserInterfaceManagement) for Common UI,
      [Modular Weather System](https://github.com/Elmarath/ModularWeatherSystem),
      [Project Active Info Getter](https://github.com/Elmarath/ProjectActiveInfoGetter) and
      [Thumbnail Creator](https://github.com/Elmarath/ThumbnailCreator).
    tags: [Open source, Tools]
code:
  title: Load everything, then merge once
  note: >-
    From [Easy Skeletal Mesh Merge Async's source](https://github.com/Elmarath/EasySkeletalMeshMergeAsync).
    The task collects the soft references, loads them in one asynchronous request and merges only when
    all of them have arrived. Keeping the handle lets a newer request cancel this one cleanly.
  lang: cpp
  source: |
    void ULoadSkeletalMeshesAndMergeTask::StartLoadingSkeletalMeshes()
    {
    	TArray<FSoftObjectPath> PathsToLoad;

    	TArray<TSoftObjectPtr<USkeletalMesh>> SkeletalMeshesToMerge = TaskMergeParameters.SkeletalMeshesToMerge;
    	SkeletalMeshesToMerge.Add(TaskMergeParameters.BaseMesh);
    	for (const TSoftObjectPtr<USkeletalMesh>& Mesh : SkeletalMeshesToMerge)
    	{
    		if (!Mesh.IsNull())
    		{
    			PathsToLoad.AddUnique(Mesh.ToSoftObjectPath());
    		}
    	}

    	FStreamableManager& StreamableManager = UAssetManager::GetStreamableManager();

    	ActiveLoadHandle = StreamableManager.RequestAsyncLoad(PathsToLoad,
    		FStreamableDelegate::CreateUObject(this, &ULoadSkeletalMeshesAndMergeTask::OnSkeletalMeshesLoaded));
    }

    void ULoadSkeletalMeshesAndMergeTask::CancelTask()
    {
    	if (ActiveLoadHandle.IsValid())
    	{
    		ActiveLoadHandle->CancelHandle();
    		ActiveLoadHandle.Reset();
    	}

    	OnMeshMergeCancelled.Broadcast();
    }
order: 5
---

## How the plugins come about

Every plugin started as a system my own projects needed, such as my game
[Thrall Guard](/work/thrall-guard). When one turned out to be useful on its own, I pulled it out, made it
general enough for other games, and published it. That keeps them grounded: each one solves a problem a
real game had.

## What goes into each one

- **A C++ core with a Blueprint API**, so programmers can extend it and designers can use it without code.
- **Multiplayer from the start**: replication is part of the design, not added later.
- **Built on Unreal's own frameworks** wherever it fits: the Gameplay Ability System, StateTree, Gameplay
  Tags, Data Assets, Subsystems and the Streamable Manager.
- **Documentation** on this site for every plugin, with setup guides, examples and, for several, video
  walkthroughs.

## Results

- Over 4,500 sales on [Fab](https://www.fab.com/sellers/Elmarath).
- Eight plugins documented in the [docs](/docs), and six open-source plugins on
  [GitHub](https://github.com/Elmarath).
