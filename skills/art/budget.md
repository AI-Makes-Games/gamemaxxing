# What to make, and what it costs

Target: **450 to 550 credits per game** (adventure), less for the others. Stop when your own spending reaches 650. Prices below are from SpriteCook (`list_character_workflows`), November 2026. Check that tool again if a price looks different.

- A base character: **12**.
- In one animation run, the first animation costs **20** and each extra one **14**.
- Some poses need a one-off prep picture: **12** each.
- A still picture (`generate_game_art`): **12**.

## Per template

| Template | Perspective | Hero animations | Hero cost | Each other character | Others' cost |
| --- | --- | --- | --- | --- | --- |
| Adventure | `topdown` | `idle`, `idle_right`, `walk_right`, `attack`, `hurt` (leave out `attack` and `hurt` in a no-fighting game: about 84) | about 112 | `idle`, `idle_right`, `walk_right` | about 84 |
| Platformer | `platformer` | `idle`, `walk`, `jump`, `hurt` | about 86 | `idle`, `walk` | about 58 |
| Story | (portraits) | none: one portrait with `generate_game_art`, about 64x64, `aspect_ratio: "1:1"` | 12 | one portrait each | 12 |

- **Adventure:** `idle_right` never shows on screen; the game uses the front-facing `idle` when standing still. It's only there because SpriteCook's `walk_right` needs it. The side-facing `walk_right` is mirrored when moving left.
- **Story:** a character has one portrait. The game can't swap faces per scene, so don't offer extra expressions.

## A typical game

| Asset | Count | Adventure | Platformer | Story |
| --- | --- | --- | --- | --- |
| Hero | 1 | 112 | 86 | 12 |
| Other characters | up to 3 | 252 | 174 | 36 |
| Props and items (64x64) | up to 8 | 96 | 96 | 0 |
| Backgrounds (story: `aspect_ratio: "16:9"`, about 320x180) | one per place, up to 6 | 0 | 0 | 72 |
| Logo (shown on the title screen) | 1 | 12 | 12 | 12 |
| **Total** | | **about 472** | **about 368** | **about 132** |

Leave room for a few "try again"s (12 each). Story games have credits to spare: a background for every scene, or another character.

**Credits and shared accounts:** count what *this* student spends by adding up each job's `credits_used`. If several students share one SpriteCook account, the balance falls with everyone's spending. A full adventure game uses more than half a Starter month (800 credits), so two students can't share one account. Each student needs their own.
