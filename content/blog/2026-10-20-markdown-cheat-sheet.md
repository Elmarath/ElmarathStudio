---
title: Markdown cheat sheet
authors: [denizhan]
tags: [Guide]
description: Every formatting option the site supports, in one page. Drafts only show up while running locally.
draft: true
---

This post is a **draft**, so it only appears when you run the site locally (`flutter run`). Use it as a reference while writing.

<!-- truncate -->

## Text

Regular paragraphs, **bold**, *italic*, ~~strikethrough~~, `inline code` and [links](https://dev.epicgames.com/documentation/en-us/unreal-engine). Internal links work too: [Getting started](/docs/intro).

> Blockquotes are great for quoting engine docs or players' feedback.

## Lists

- Unordered item
- Another item
  - Nested item

1. First step
2. Second step

- [x] Task lists
- [ ] are supported

## Code

```cpp
void UMyAbility::ActivateAbility(const FGameplayAbilitySpecHandle Handle,
    const FGameplayAbilityActorInfo* ActorInfo,
    const FGameplayAbilityActivationInfo ActivationInfo,
    const FGameplayEventData* TriggerEventData)
{
    Super::ActivateAbility(Handle, ActorInfo, ActivationInfo, TriggerEventData);
    UE_LOG(LogTemp, Log, TEXT("Ability activated!"));
}
```

```json
{ "Name": "MyPlugin", "Type": "Runtime", "LoadingPhase": "Default" }
```

## Tables

| Setting | Type | Default |
| --- | --- | --- |
| `TraceRadius` | `float` | `8.0` |
| `bDrawDebug` | `bool` | `false` |

## Admonitions

:::note
A plain note. Use it for side information.
:::

:::tip Pro tip
Admonitions accept an optional title after the type.
:::

:::info
Useful background information.
:::

:::warning
Something that can go wrong.
:::

:::danger
Something that will break your project.
:::

## Media

Images use normal Markdown and can live next to the post:

![Hermod's Ride](./2021-08-26-welcome/hermods-ride.jpeg)

YouTube videos are one line:

::youtube a8clpcFSLOE start=989
