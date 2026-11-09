# The day plan

Times are measured from `day_start` (normally 9:00). "Done by" is how far into the day each stage should finish.

| Clock (9:00 start) | Done by | Stage | The student leaves with |
| --- | --- | --- | --- |
| 9:00–9:30 | 0:30 | `setup` | Claude, SpriteCook and Godot working |
| 9:30–10:30 | 1:30 | `pitch`, `bible` | A hook that's their own, rules, one scene, a look |
| 10:30–11:15 | 2:15 | `art_direction` | Style and colours locked; hero and 2–3 characters approved |
| 11:15–12:15 | 3:15 | `template`, `build` | A first version they can play; animations making in the background |
| 12:15–12:45 | 3:45 | lunch | Animation jobs finish |
| 12:45–1:45 | 4:45 | `art`, `build` | The whole game playable from start to end |
| 1:45–2:30 | 5:30 | `playtest_1` | Notes on where players got stuck or bored |
| 2:30–3:30 | 6:30 | `fix` | Biggest problem fixed; guesses reviewed; title, tagline and how-to-play line checked |
| 3:30–4:00 | 7:00 | `playtest_2` | A last round of notes |
| 4:00–4:30 | 7:30 | `publish` | A public itch.io link |
| 4:30–5:00 | 8:00 | `showcase` | Everyone plays everyone's game |

A student is **behind** when the time since `day_start` is more than 20 minutes past the "Done by" of the stage they're on. They're **ahead** when they finish a stage more than 30 minutes before its "Done by". Then offer extras from [stretch.md](stretch.md) instead of starting the next stage early, especially before a playtest.

Rehearsals showed most students finish well ahead, story games most of all (often by lunch). Expect to use stretch goals.

## The scope cut (offer once, when behind)

Say it kindly and plainly, for example:

> We're about 25 minutes behind, which is completely normal. To make sure you finish with a game people can play, let's keep it to **one area, one hero, at most two other characters, and one ending**. Everything else goes on a "later" list, so none of your ideas get lost. Sound good?

If they accept, set `scope_cut` to `accepted` and move the extra ideas into `design/later.md`. If they decline, set it to `declined` and don't offer again; mention it to Hex in `notes`.
