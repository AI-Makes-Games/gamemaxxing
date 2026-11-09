---
name: bible
description: The GameMaxxing game bible. Use after the pitch passes, or when a student wants to set or change their game's hook, main action, rules, key scene or look. Collects the five inputs in the student's own words, one at a time, and writes design/game_bible.md and art_bible.json.
---

# GameMaxxing: game bible

The bible holds the things only the student can decide. Everything Claude builds later must fit inside them. This skill runs **Quest 2 · The Rulebook**, then opens **Quest 3 · The Look** with the look questions. Talk the way [tone.md](${CLAUDE_PLUGIN_ROOT}/shared/tone.md) says, and follow [quest.md](${CLAUDE_PLUGIN_ROOT}/shared/quest.md) for question cards, the words they can say, check-ins and points. The questions, what counts as an answer, and the "why I'm asking" lines are in [bible_questions.md](bible_questions.md).

## Quest 2 · The Rulebook

1. **Read `design/pitch.md`** if it exists. Remind the student of their hook in one line, so they feel the thread. Say in one line what this quest makes: "Your game bible: the rules everything else gets checked against, so the game stays yours."
2. **Ask these in order, one question card per message** ("Question N of 7"), and wait for each answer:
   1. hook
   2. main action
   3. rules
   4. one scene (its three small questions count as one)
   5. the ending feeling
   6. what gets in the way
   7. the title
   - If their pitch already answered one (for example the hook, or the Ending question), show it back and ask "Still true, or do you want to change it?" instead of asking again.
   - Tidy their words (spelling, order, short sentences). Never add ideas, characters, events or twists that they didn't pick.
   - If an answer is too thin to build from, ask one follow-up question, and remind them they can say `suggest` or `examples`.
   - `suggest`: 2–3 options built from their pitch and earlier answers. They pick one and change it. `examples`: from [game_examples.md](${CLAUDE_PLUGIN_ROOT}/shared/game_examples.md). `skip`: park it, and come back to it before the template step (the build needs every answer except the title).
3. **The scene is theirs.** Never write it, even a first draft, even if they ask. Ask the three questions in bible_questions.md one at a time and stitch their answers together in their words. If they're stuck on one, `suggest` can offer 2–3 options for that small question only. Then read it back and ask "Is this your scene?"
4. **The two questions the build needs:**
   - **The ending feeling**: "How should the player feel in the last 10 seconds of your game?" (one feeling).
   - **What gets in the way** (adventure and platformer): "Who or what gets in the player's way?" Their answer becomes the creatures. If it's people, that's fine; if nothing, say the game will still need a small challenge and offer two or three ideas from their scene.
5. **Name the game.** "What's your game called? A working title is fine, you can change it any time." If they really can't choose, write "Untitled" and say you'll ask again at the fix stage. Save it as `quest.title`.
6. **Points** as you go (see quest.md):
   - ⭐ +10 XP for each answer.
   - 💎 +10 Depth for each rule specific enough to test (up to 3), and the 📜 Rule Maker badge at three.
   - 💎 +15 for a scene with one clear choice or feeling.
   - 💎 +15 if the idea's real-life source comes up here (and the pitch didn't already earn it).
7. **Pick the template** from their main action (see bible_questions.md) and tell them in one line which kind of game it'll be, and why. Save it as `template_hint` in `gamemaxxing/progress.json`.
8. **Check each rule can be kept** (in its own message, before the check-in) by that template (see "What the templates can do" in bible_questions.md). If one can't ("the clock tower always shows how long is left" needs an on-screen timer the platformer doesn't have), say so kindly in one line and offer the closest thing it can do, or put it on the **Full game list** in `design/later.md`. Don't leave a rule the game will break.
9. **Bring back anything parked.** Ask each question under "Come back to" in `design/later.md` again (the build needs every answer except the title). Then **write `design/game_bible.md`** (format in bible_questions.md).
10. **Finish Quest 2** as quest.md says: the check-in ("Here's your game bible in three lines. Happy with it so far? Nothing's locked in."), the boss question offer, and the quest complete moment.

## Quest 3 · The Look (the first part)

11. **Open Quest 3** (the opening from quest.md), then ask the look questions from bible_questions.md as question cards: their 3 pictures and 3 words, then their hero. Award 💎 +10 for a hero detail only they'd think of.
12. **Build `art_bible.json`** from the look, following [art_bible_format.md](art_bible_format.md). Pixel art only. The hero's prompt comes from the student's own description of their hero: never invent who the hero is. You will have to draft the palette and fill in small details in the prompts. Every one of those drafts is a creative guess, so log each with the `gamemaxxing:decisions` skill. Group small related guesses (for example, all the palette colours) into one entry, so the log stays short enough to review.
13. **Show the student a short summary** of the art bible: the style in one line, the colours, and the list of characters and things to draw. Ask "Does this look like your game? We can change anything." Change what they want.
14. **Update `gamemaxxing/progress.json`:** set `stage` to `art_direction` and add its start time to `stage_started` (`quest.quest` stays 3). Rewrite `quest_data.js`. Say the next step is making their hero's art, and if the `start` skill sent you, run `gamemaxxing:art` with the Skill tool.

## Rules

- One question card per message.
- Rules must be things the game always or never does. "Fun" or "hard" aren't rules yet: ask what makes it so.
- Keep it to about 30 minutes. If the student wants to add lots of ideas, write extras to `design/later.md` and keep going.
- Later, the `build` skill checks every change against the rules in `design/game_bible.md`. Write them so they can be checked.
