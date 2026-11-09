# The first build: put the student's scene in

The template still holds a sample game (the gardener, the courier, or the bakery). Turn it into the student's game, using `design/game_bible.md`. Keep the template's structure: the same kinds of things, the same files, the same way of ending. Do it in this order, testing after each step.

1. **Save a checkpoint:** `tools/checkpoint.gd -- save "before first build"`.
2. **The people and creatures** (`entities.json`): replace the sample characters with the student's (from their scene and art bible). Keep every entity's `kind`, `char` and fields; change `name`, `color`, `sprite` (use the ids from `art_bible.json`, so art drops in later) and numbers. Remove sample things they don't need; keep at least one of each kind the template uses to finish (a goal, and the door and key if the adventure's ending needs them).
   - **Creatures:** use the bible's "what gets in the way". Never keep the sample's creatures (slimes, beetles) in the student's game. If the bible has no answer, ask that one question now.
   - **No fighting** in their rules (adventure): set `"can_attack": false` and `"enemy_touch": "send_back"` in `game.json`, and update `how_to_play`.
3. **The words** (`story.json`): rewrite the scenes around the student's scene, in their words wherever possible. The decision in their scene becomes a choice. Its options set flags that the endings check. Short, plain lines. Everything you write yourself goes in the decision log.
4. **The place** (`level.txt`, adventure and platformer): reshape the sample map to suit the scene (where things are, a bit of character), keeping every row the same length and keeping the route the bot can follow. Story template: set `background` and the portraits in each scene.
5. **The endings** (`game.json`): at least two. One should match the student's ending feeling (in `design/game_bible.md`). Each ending's `if` must use flags their choices set.
6. **Test and save** with `tools/checkpoint.gd -- save-tested "first build"`, and check the other endings with `-- choice=1`. Then show them the game. Say: "This is your scene, playable. Claude filled in some gaps, and they're all in your decision log for later."

Keep it to about 30 minutes. If the scene is big, build the smallest playable version and put the rest in `design/later.md`.
