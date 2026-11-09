---
name: bible
description: The GameMaxxing game bible. Use after the pitch passes, or when a student wants to set or change their game's hook, main action, rules, key scene or look. Collects the five inputs in the student's own words, one at a time, and writes design/game_bible.md and art_bible.json.
---

# GameMaxxing: game bible

The bible holds the five things only the student can decide. Everything Claude builds later must fit inside them. Talk the way [tone.md](${CLAUDE_PLUGIN_ROOT}/shared/tone.md) says. The questions, what counts as an answer, and examples are in [bible_questions.md](bible_questions.md).

## How to run it

1. **Read `design/pitch.md`** if it exists. Remind the student of their hook in one line, so they feel the thread.
2. **Ask for the five inputs in this order, one per message:** hook, main action, rules, one scene, the look. Wait for each answer.
   - If their pitch already answered one (for example the hook), show it back and ask "Still true, or do you want to change it?" instead of asking again.
   - Tidy their words (spelling, order, short sentences). Never add ideas, characters, events or twists of your own.
   - If an answer is too thin to build from, ask one follow-up question. Offer two or three examples only if they're stuck, and say they're examples.
3. **The scene is theirs.** Never write it, even a first draft, even if they ask. Ask the three questions in bible_questions.md one at a time and stitch their answers together in their words. Then read it back and ask "Is this your scene?"
4. **Two short questions the build needs:**
   - **The ending feeling,** if the pitch didn't pass its Ending question: "How should the player feel in the last 10 seconds of your game?" (one feeling).
   - **What gets in the way** (adventure and platformer): "Who or what gets in the player's way?" Their answer becomes the creatures. If it's people, that's fine; if nothing, say the game will still need a small challenge and offer two or three ideas from their scene.
5. **Name the game.** Ask: "What's your game called? A working title is fine, you can change it any time." Use their title in the bible; if they really can't choose, write "Untitled" and say you'll ask again at the fix stage.
6. **Pick the template** from their main action (see bible_questions.md) and tell them in one line which kind of game it'll be, and why. Save it as `template_hint` in `gamemaxxing/progress.json`.
7. **Check each rule can be kept** by that template (see "What the templates can do" in bible_questions.md). If one can't ("the clock tower always shows how long is left" needs an on-screen timer the platformer doesn't have), say so kindly in one line and offer the closest thing it can do, or put it in `design/later.md`. Don't leave a rule the game will break.
8. **Write `design/game_bible.md`** (format in bible_questions.md).
9. **Build `art_bible.json`** from the look, following [art_bible_format.md](art_bible_format.md). Pixel art only. The hero's prompt comes from the student's own description of their hero: never invent who the hero is. You will have to draft the palette and fill in small details in the prompts. Every one of those drafts is a creative guess, so log each with the `gamemaxxing:decisions` skill. Group small related guesses (for example, all the palette colours) into one entry, so the log stays short enough to review.
10. **Show the student a short summary** of the art bible: the style in one line, the colours, and the list of characters and things to draw. Ask "Does this look like your game?" Change what they want.
11. **Update `gamemaxxing/progress.json`:** set `stage` to `art_direction` and add its start time to `stage_started`. Celebrate in one line: "Your game bible is done. This is the heart of your game." Then say the next step is choosing the look of the main characters, and if the `start` skill sent you, run `gamemaxxing:art` with the Skill tool.

## Rules

- One question per message.
- Rules must be things the game always or never does. "Fun" or "hard" aren't rules yet: ask what makes it so.
- Keep it to about 30 minutes. If the student wants to add lots of ideas, write extras to `design/later.md` and keep going.
- Later, the `build` skill checks every change against the rules in `design/game_bible.md`. Write them so they can be checked.
