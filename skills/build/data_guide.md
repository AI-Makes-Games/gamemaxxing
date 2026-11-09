# The data files

All three templates read the same files. Keep them valid JSON: a missing comma or quote makes the test bot print `RUN FAILED` with the file and line.

## `game.json`

| Field | Meaning |
| --- | --- |
| `title`, `tagline` | Shown on the title screen. Also set `config/name` in `project.godot` to the title. |
| `how_to_play` | One line of controls, shown on the title screen. |
| `colours` | Hex colours. All: `background`, `panel` (dialogue box; make it differ from `background`), `text`, `accent`. Adventure and platformer: `health`. Adventure: `floor`, `wall`, `water`. Platformer: `ground`, `ground_top`, `platform`, `spikes`. |
| `tile_size` | Size of one map square in pixels (32). |
| `player` | `sprite` (art id, usually `hero`), `color` (placeholder), `health`. Adventure: `speed`, `attack_damage`, `can_attack` (`false` turns off swinging). Platformer: `speed`, `jump_speed`, `gravity`, `max_fall`, `coyote_time` (seconds you can still jump after leaving a ledge), `jump_buffer` (seconds a jump pressed early still counts). |
| `enemy_touch` | Adventure only: `"hurt"` (default, costs health) or `"send_back"` (being caught sends the player back to the last checkpoint, and the hearts are hidden). For gentle games. |
| `endings` | A list, checked in order; the first whose `if` is true is used. Each has `id`, `if` (a condition, `""` means always), `title`, `text`. Put the catch-all ending last. |
| `start_scene` | Story only: the first scene. |
| `timed_choices` | Story only: `true` turns on countdowns for scenes that have a `timer`. Off by default. |

## `story.json`

```json
{
  "start_flags": { "kindness": 0 },
  "scenes": {
    "scene_id": {
      "speaker": "Ada",
      "set": { "met_ada": true },
      "text": ["A line.", { "if": "met_ada", "t": "Shown if true.", "else": "Shown if not." }],
      "options": [
        { "t": "What the player clicks", "o": "What happens (shown after)", "if": "has:key",
          "set": { "flag": true }, "add": { "kindness": 1 }, "give": "key", "take": "key",
          "next": "another_scene", "end": true }
      ]
    }
  }
}
```

- **Conditions** (`if`): `flag`, `!flag`, `has:item`, `counter>=2`, `counter<1`, `mood=angry`, joined with `&` (all must be true).
- **`next`** goes to another scene. With no `next` the conversation ends (adventure and platformer) or the story ends (story).
- **`end`**: `true` ends the game and picks an ending by the conditions in `game.json`; a string ends it with that ending's id.
- **Story only:** a scene can have `background` (a background id), `left` and `right` (character ids), `timer` (seconds) and `timeout_option` (which choice to take when time runs out).

## `entities.json`

Each entry is `"id": { ... }`. The id is how other files refer to it. `sprite` is the art id (art goes in `art/<sprite>/`; `art/logo/` is shown on the title screen). `color` and `shape` are used until the art arrives. `char` is the letter that places it in `level.txt`.

| `kind` | Template | Fields |
| --- | --- | --- |
| `npc` | adventure, platformer | `name`, `talk`: a scene id, or a list like `[{"if": "has:key", "scene": "x"}, {"scene": "y"}]` (first match wins). Platformer signs use `shape: "sign"`. |
| `enemy` | adventure | `behaviour`: `wander`, `chase` or `keep_away` (keeps its distance and throws). `health`, `speed`, `sight`, `damage`, `shoot_every` (keep_away). |
| `enemy` | platformer | `behaviour: "patrol"` (walks back and forth, turns at walls and edges; landing on it stops it). `speed`, `damage`. |
| `item` | adventure, platformer | Picked up by touching. `name`. Optional `set` (flags to set when picked up). |
| `collectible` | platformer | Counted on the ending screen. `name` (plural, e.g. "letters"). |
| `door` | adventure | Blocks the way until opened. `needs` (an item id), and/or `opens_if` (a condition; opens by itself when true). |
| `checkpoint` | adventure, platformer | The player comes back here after losing all health. |
| `goal` | adventure, platformer | Touching it ends the game. |
| `character` | story | `name`, `color`, `sprite`: shown as a portrait. |
| `background` | story | `name` (shown top-left), `color`, `sprite`. |

## `level.txt` (adventure and platformer)

One letter per square. Every row the same length. Fixed letters:

| Letter | Adventure | Platformer |
| --- | --- | --- |
| `#` | wall | ground (solid) |
| `.` | floor | air |
| `~` | water (blocks walking) | (unused) |
| `=` | (unused) | one-way platform (jump up through it) |
| `^` | (unused) | spikes |
| `P` | player start | player start |

Any other letter is looked up in `entities.json` by `char`. Exactly one `P`. The platformer needs a solid edge on the left and right (the template's `#` columns) and a goal.
