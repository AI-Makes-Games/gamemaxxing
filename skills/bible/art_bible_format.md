# `art_bible.json`

The art skill reads this file to make every picture in the game, so all the art matches. Write it at the top of the student's game folder.

## Shape

```json
{
  "style": {
    "pixel": true,
    "perspective": "top-down three-quarter",
    "base_size": "64x64",
    "words": ["cosy", "misty", "warm"],
    "pictures": ["a foggy harbour at dawn", "an old storybook illustration", "a cosy cafe at night"],
    "style": "16-bit pixel art, top-down three-quarter view, readable shapes, 1px dark outline, soft light from the upper left",
    "palette": ["#1E2433", "#3B4A5C", "#6E8A94", "#C9D6CF", "#F2E3C6", "#D98E5F", "#8C4A3A", "#4F6B4A"],
    "rules": [
      "No text or logos inside sprites.",
      "Make each character once, then animate that same character. Never remake it for each animation."
    ]
  },
  "characters": [
    {
      "id": "hero",
      "role": "the player",
      "prompt": "<what they look like, in the student's words where possible>",
      "animations": ["idle", "walk", "attack", "hurt"]
    }
  ],
  "props": [
    { "id": "key", "prompt": "<...>" }
  ],
  "ui": [
    { "id": "logo", "prompt": "<the game title as a logo>" }
  ]
}
```

## How to fill it

- **`pixel`** is always `true` (pixel art only for the workshop).
- **`perspective`** comes from the template:
  - `adventure`: "top-down three-quarter"
  - `platformer`: "side view"
  - `story`: "portraits and backgrounds"
- **`words`** and **`pictures`**: the student's own, as given.
- **`palette`**: up to 16 colours that match their pictures and words. Log it as a guess.
- **`style`**: one line combining pixel art, the perspective, and their 3 words. Log it as a guess.
- **`characters`**: the hero, plus up to 3 others from their scene (and whatever gets in the player's way). Use the animation lists in the art skill's `budget.md`:
  - adventure hero: `idle`, `idle_right`, `walk_right`, `attack`, `hurt`
  - platformer hero: `idle`, `walk`, `jump`, `hurt`
  - story: no animations, just a portrait
  - If the student's rules say nobody gets hurt or there's no fighting, leave out `attack` and `hurt`.
- **`props`**: up to 8 things from their scene and rules (keys, doors, pickups, story backgrounds).
- **`ui`**: just the logo (it's shown on the title screen). The game draws its own ground, walls and text box, so there are no tiles or panels to make.

Use the student's descriptions in prompts wherever possible. Anything you add (a hair colour, a hat, a material) is a guess: log it with the decisions skill.

The art budget (in the art skill) allows 1 hero, up to 3 others, up to 8 props and a logo. Don't list more than that here. Put extra ideas in `design/later.md`.
