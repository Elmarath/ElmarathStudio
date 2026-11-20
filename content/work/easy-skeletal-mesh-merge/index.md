---
title: Easy Skeletal Mesh Merge Async
kind: Plugin
role: "Solo developer: C++, Blueprint API and documentation"
team: Solo
engine: Unreal Engine 5
summary: >-
  Modular characters usually cost a draw call per part, and Epic's Skeletal Merging plugin, which fixes
  that, is tricky to drive and leaves hard references and replication to you. Easy Skeletal Mesh Merge
  Async wraps it in one component: meshes load in the background and merge once they've all arrived, a
  newer request cancels the one in progress, and the merge replicates so every player sees the same character. It's
  open source on GitHub and published on Fab, with documentation and a video walkthrough.
video: merge.mp4
tech: [C++, Async loading, Replication, Skeletal Merging]
links:
  fab: https://www.fab.com/listings/616906a0-c73d-4e7a-9002-866a6d9751d5
  github: https://github.com/Elmarath/EasySkeletalMeshMergeAsync
  docs: /docs/easy-skeletal-mesh-merge-async
features:
  - title: Background loading, one merge
    text: >-
      Parts are soft references, loaded together in one asynchronous request through the Streamable
      Manager, and merged once they've all arrived: equipping never waits on a blocking load.
    media: merge.mp4
    tags: [Async, C++]
  - title: Cancel on the next request
    text: >-
      Each merge is a task. A new request cancels the one in flight, so fast equipment changes can't
      race each other and leave clients on different meshes.
    tags: [Tasks, Stability]
  - title: Replicated results
    text: >-
      The merge parameters replicate, and every client runs the same merge, so all players see the
      same character.
    tags: [Replication, Multiplayer]
  - title: One component, any actor
    text: >-
      Add `UEasySkeletalMeshAsyncMergeable` to any actor, or use it in place of a character's own
      skeletal mesh component. Blueprint and C++.
    tags: [Blueprints, API design]
code:
  title: Load everything, then merge once
  note: >-
    From [the plugin's source](https://github.com/Elmarath/EasySkeletalMeshMergeAsync). The task collects
    the soft references, loads them in one asynchronous request and merges only when all of them have
    arrived. Keeping the handle lets a newer request cancel this one cleanly.
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
order: 4
---
