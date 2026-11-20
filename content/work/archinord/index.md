---
title: Archinord Software
kind: Studio
role: C++ Developer
location: Türkiye · Office
period: Jul 2024 – Jul 2025
team: 3 people
engine: Unreal Engine 5
summary: >-
  Archinord Software builds interactive architectural visualisations that construction companies use to
  sell homes, on kiosks and screens. In a three-person team I led their development in Unreal Engine 5
  and AWS, helping the studio partner with 20+ construction companies in its first six months. I built
  one core project with a Game Feature plugin per client, delivered from AWS S3: clients sign in, see
  only their own projects, and get the latest version on opening one. Every improvement to the core
  reached all of them at once.
video: cover.mp4
tech: [C++, Game Features, AWS, World Partition, Mass, Cesium, MetaHumans, Common UI, UI materials, ChunkDownloader, Plastic SCM]
links:
  projects: https://archinord.com/moduller/sunum
  website: https://www.archinord.com/en
stats:
  - { value: "20+", label: construction companies partnered in the first six months }
  - { value: "20+", label: "client projects, each its own Game Feature plugin" }
  - { value: "1", label: "core project: one fix or optimisation improves every client's project" }
features:
  - title: One core, a plugin per client
    text: >-
      The shared features live in one Unreal Engine project; each client's buildings and interiors are a
      Game Feature plugin built for their needs. When I optimised the core or added content such as new
      trees, every client's project got it without extra work.
    media: kiosk.webp
    tags: [Game Features, C++, Architecture]
  - title: Updates on sign-in
    text: >-
      Plugins are hosted on AWS S3 and delivered with Epic's ChunkDownloader, which I extended. Clients
      sign in with their company email, see only their own projects, and opening one downloads its latest
      version if theirs is out of date.
    media: aerial.jpg
    tags: [ChunkDownloader, AWS S3, C++]
  - title: Live data with OnlineAttributeSheet
    text: >-
      A plugin I wrote that keeps a sheet of values in sync from the company website (or Google Sheets),
      in game and in the editor. Prices, availability and each apartment's interior come from it, so the
      building on screen always shows what's available now, without rebuilding the project.
    media: archinord.mp4
    tags: [C++, Plugin, Blueprints]
order: 2
---

## Content delivery

Clients changed their content often, the interiors especially, and wanted to show their own customers the
latest version straight away. Getting every change to them took time and back and forth on both sides.
Splitting each client's content into its own plugin, delivered on demand, turned an update into something
the client simply received the next time they opened their project.

```mermaid
flowchart LR
  core["Core project"] --> a["Client A plugin"]
  core --> b["Client B plugin"]
  core --> c["20+ more"]
  a & b & c --> s3[("AWS S3")]
  s3 --> dl["ChunkDownloader"]
  dl --> kiosk["Kiosk app"]
```

The core project holds the shared features, tools and optimisations. Each client's content is a Game Feature
plugin on AWS S3. The kiosk app signs clients in with their company email, shows only their projects, and
uses my extended ChunkDownloader to fetch the latest version of a project when it's opened.

It paid off in both directions: clients saw their changes sooner and needed less back and forth with us,
and work on the core, from optimisations to new assets, improved every client's project at the same time.

## OnlineAttributeSheet

Most of what a visualisation shows changes after it ships: prices, which apartments are still available,
the interiors on offer. I wrote a plugin, **OnlineAttributeSheet**, so none of that needed a rebuild.

- **Refreshers** are UObjects that fetch a sheet of values from a source: Google Sheets, or in our case the
  company website.
- **Values are stored as `FName`s**, which keeps refreshing cheap, and converted on demand into whatever a
  system needs: Gameplay Tags for availability and extra attributes, integers for prices, or levels.
- **Custom Blueprint nodes** read the last refreshed value as the type you ask for.
- **It works in the editor too**, so the live values are there while building the project, not only at runtime.

```mermaid
flowchart LR
  site["Company website<br/>or Google Sheets"] --> ref["Refreshers"]
  ref --> sheet["Sheet of FName values"]
  sheet --> tags["Gameplay Tags<br/>availability, attributes"]
  sheet --> ints["Integers<br/>prices"]
  sheet --> lvls["Levels<br/>interiors"]
```

For example, each apartment's interior is mapped to a sheet value: pressing **Virtual Tour** on an
apartment loads that interior as a Level Instance to walk through. The sheets ended up everywhere in the
project, from sign-in details to the points of interest shown around a development, such as hospitals and
bus stops.

## Built with

Unreal Engine 5 and C++, with Game Features, World Partition, Mass, Cesium, MetaHumans, Common UI and UI
materials. Content was delivered from AWS S3, and the team
worked in Plastic SCM.
