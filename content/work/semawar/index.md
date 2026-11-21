---
title: Semawar
company: Jamination 5
kind: Game jam
role: Gameplay Programmer and event organiser
location: Marmara University · İstanbul
period: May 2022
team: "6 people: 3 programmers, 3 artists"
engine: Unity 2021.3
video: gameplay.mp4
summary: >-
  Semawar is a local two-player capture-the-flag game in which a whirling semazen fights a tank. We
  made it in 48 hours for Jamination 5, on the theme "Every input does two things". In a team
  of six I came up with the spinning semazen, programmed his movement, input and projectiles, and spent
  our spare six hours on power-ups. As founder of Marmara University's game development club, I also
  brought the jam to our campus: over 50 people, sponsors and a building to jam in.
tech: [Unity, C#, Local multiplayer, Game jam, Event organising]
links:
  itch: https://aenin.itch.io/semawar
  github: https://github.com/mrsagcan/semawar
  jam: https://itch.io/jam/jamination-5
  press: https://mobidictum.com/tr/jamination-5-game-jam-turk-oyun-gelistiricileri-bir-araya-getiriyor/
stats:
  - { value: "48 hrs", label: "to make it, on the theme \"Every input does two things\"" }
  - { value: "50+", label: people at the Marmara University venue I organised }
  - { value: "34", label: games entered in Jamination 5 }
features:
  - title: One button, two things
    text: >-
      The semazen never stops spinning; it's his whole thing. Hold the attack button and he charges
      forward in whatever direction he happens to be facing. Let go and he spins the other way. I
      programmed the movement and the input for both players, sharing one PC and, occasionally, one
      grudge.
    media: spin.mp4
    tags: [Movement, Input, C#]
  - title: Projectiles and power-ups
    text: >-
      The projectiles, and then, with the game done and six whole hours of the jam left, a power-up
      system nobody asked for: a speed boost, a shorter cooldown between shots, and
      shrinking, because a smaller dervish is a harder dervish to hit. Subtle, the projectiles were not.
    media: editor.jpg
    tags: [Gameplay, C#, Unity]
  - title: Bringing the jam to Marmara University
    text: >-
      As founder of Marmara University's game development club, I organised the event on our campus,
      [one of four venues in İstanbul](https://mobidictum.com/tr/jamination-5-game-jam-turk-oyun-gelistiricileri-bir-araya-getiriyor/),
      for over 50 people: talking with the dean and the university to get the space, and helping find
      sponsors, which got everyone Jamination 5 T-shirts.
    media: team.jpg
    tags: [Organising, Community]
timeline:
  - { date: 27 May 2022, text: "Jamination 5 starts: 48 hours, theme \"Every input does two things\"" }
  - { date: Last 6 hours, text: "The game works, so naturally I add power-ups: speed, shot cooldown and size" }
  - { date: 29 May 2022, text: "Submitted to Jamination 5 and shown to our community and the online jam" }
order: 5
---

## The idea

Jamination 5 ran for 48 hours, from 27 to 29 May 2022, with
[34 games entered](https://itch.io/jam/jamination-5/entries). The theme was *Every input does two
things*. At the time, a song called *Mesneviden Ders Aldım* was everywhere on social media, and our team
could not stop joking about it. Somewhere in there the idea arrived: a semazen, the whirling dervish, who
never stops spinning. One input, two things: hold it and he moves forward the way he's facing, let go and
he spins the other way.

Then we asked the obvious next question: what is the least fair opponent for a spinning man in a robe?
A tank. Obviously a tank.

![A semazen in a long robe spins in front of a red flag while a small green tank waits behind him](./cover.png)

The result is a local capture the flag for two players on the same PC. You grab the other player's flag
and carry it back to your own platform, which only counts if your own flag is still sitting there, and
you try not to die on the way. First to three wins. Our artists and
programmers built several levels for it, from a desert to a grassy maze, so the battlefield keeps
changing even when the dervish doesn't stop.

## What I built

I programmed the characters' movement, the input for both players and the projectiles. The other two
programmers wrote the UI and the game manager with the win conditions, and our artists made the levels,
the models and the music.

Then something rare happened at a game jam: we finished early. With six hours to spare, instead of
sleeping like a reasonable person, I added a power-up system: a speed boost, a shorter cooldown between
shots, and a size decrease.

The [source is on GitHub](https://github.com/mrsagcan/semawar), a Unity 2021.3 project. Read it at your
own risk (see *Looking back*).

## The music

[breadcred](https://breadcred.itch.io/) wrote an 8-bit track inspired by *Mesneviden Ders Aldım*, and it
is a banger. It's the first thing people remember, and together with the, let's say, *unusual* setting,
it's what made Semawar stand out when we showed it to our own community and to the online Jamination 5
community.

## Bringing the jam to Marmara University

Jamination 5 ran at four venues in İstanbul at the same time, plus online on Discord, organised by game
development clubs from universities around Türkiye. İstanbul Technical University handled the technical
side of the jam. As the founder of the Marmara University game development club, my job was the place
itself: I organised the event at our university, which
[Mobidictum's preview of the jam](https://mobidictum.com/tr/jamination-5-game-jam-turk-oyun-gelistiricileri-bir-araya-getiriyor/)
lists at the Faculty of Technology in Maltepe, together with the university's computer engineering club,
MACSEC. That meant talking with the dean and the university to get the building for the weekend,
and helping find sponsors, which got everyone a Jamination 5
T-shirt, so at least everybody went home with something that fit. Over 50 people joined us there.

![Stacks of folded Jamination 5 T-shirts in three colours laid out along a classroom table](./t-shirts.jpg)

*The T-shirts, neatly folded. They stayed that way for about five minutes.*

## Looking back

I'm not proud of the code. It was written in 48 hours, and it shows. But people really wanted to play it,
and they enjoyed it, and that part I'm very proud of.

Made by [Aenin](https://aenin.itch.io), [elmarath0](https://elmarath0.itch.io) (me),
[gittem01](https://gittem01.itch.io), [fathizubinof](https://fathizubinof.itch.io),
[breadcred](https://breadcred.itch.io) and [benes](https://benes.itch.io).
