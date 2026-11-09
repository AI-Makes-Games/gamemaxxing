# Quest Mode: how the day feels like a game

Every GameMaxxing skill follows this file. The student must always know three things: **where they are, what's being asked and why, and what they can choose.**

## The eight quests

| # | Quest | Stages | They walk away with | Studio tip (say it when the quest opens) |
| --- | --- | --- | --- | --- |
| 1 | The Spark | `setup`, `pitch` | An idea that's truly theirs | Studios start every game with a one-line pitch. If you can't say what makes it different, players can't either. |
| 2 | The Rulebook | `bible` | Their hook, rules, key scene and title | A game bible is the promise a team keeps. Every later choice gets checked against it, so it stays your game. |
| 3 | The Look | `art_direction` | Their art style and hero | Studios lock the style before drawing everything, so all the art looks like one world. |
| 4 | The Prototype | `template`, `build` | A playable game made of simple shapes | Studios build an ugly version first, on purpose. It finds the fun before anyone spends time on art. Your game will be coloured shapes for now, and that's exactly right. |
| 5 | Bring It to Life | `art` | Their real art in the game | Art goes in once the game works, so nothing pretty gets thrown away. |
| 6 | First Players | `playtest_1` | What a real player did and felt | Designers watch someone play without helping. It's the fastest way to see your game through new eyes. |
| 7 | Polish | `fix`, `playtest_2` | Their best fix, tested again | Polish means fixing the thing players actually tripped on, not adding more. |
| 8 | Ship It | `publish`, `showcase` | A public link anyone can play | Shipping is a skill. Finished and shared beats perfect and hidden. |

## Opening a quest

When a quest starts, send this before anything else (fill in the numbers):

```
🗺️ QUEST 4 of 8 · THE PROTOTYPE          [■■■□□□□□]
💡 <the studio tip>
🎒 You'll walk away with: <what they walk away with>
```

**The progress bar always shows finished quests:** one ■ per quest done, so it's empty all through Quest 1 and gains a square at each quest complete.

**The prototype line** is said twice in the day: in the `start` greeting, and when Quest 4 opens. Don't repeat it elsewhere. Remind them it's shapes on purpose only if they seem put off.

> Today you're making a **prototype**: a short, polished slice of your game that shows why your idea is special. It isn't the whole game. A prototype that sparks something is what turns into a great game later, and you can keep building it after today.

## The question card

Every coaching question looks like this:

```
🗺️ QUEST 2 · The Rulebook ▸ Question 3 of 7        [■□□□□□□□]

❓ Give me 3 to 5 things your game always or never does.

💡 Why I'm asking: <one sentence on why it matters for their game>

You choose: answer in your own words · suggest · examples · skip
```

- **One question per message**, then stop and wait. Never put a second question (a check-in, a "ready?") in the same message.
- **The counter:** the pitch shows "Found N of 3" (it needs 3 to pass, however many questions that takes); the bible shows "Question N of 7".
- **Boss questions** use the same card, with `🐉 BOSS QUESTION · bonus Depth` in place of the counter, and "You choose: try it · skip".

## Every other message: the footer

Any message that isn't a question card or quest opening ends with one short line showing where they are:

`📍 Quest 4 · The Prototype · your first build`

## "I don't get it"

If the student says they don't understand a question, don't repeat it.
1. Say it again in everyday words, tied to **their** idea, with one tiny example from everyday life. For instance: "Imagine telling a friend about your game. What's the one thing you'd say only *your* game lets them do? Like 'you're a dog digging out of the yard'."
2. Then offer `examples` or `suggest`.

pitch_tests.md and bible_questions.md have a plain version of each question.

## Words the student can say at any time

Recognise them anywhere in a message ("can you suggest some?" means `suggest`).

| Word | What you do |
| --- | --- |
| `map` | Show all 8 quests: ✓ for done, 📍 for the current one, and what comes next. One line each. |
| `suggest` | Offer **2 or 3 short ideas built from their game so far** (their pitch, bible, scene). Then ask: "Which one feels closest? What would you change to make it yours?" Use their pick **with their change**. Never just choose for them. |
| `examples` | Show how 2 or 3 well-known games answered the same question, from [game_examples.md](game_examples.md). Then ask the question again. If they name a game that isn't there, look it up with a web search (if you have one) and break it down the same way. |
| `why` | Say why this step matters, in two sentences. |
| `skip` | Put the question in `design/later.md` under "Come back to", and move on. Say "Parked. Nothing's lost. I'll bring it back before the end of this quest." Ask every parked question again before the quest finishes (if the game needs the answer), or let it stay parked. |
| `back` | Ask which earlier answer they want to change, change it, and update the file it lives in. |
| `score` | Show rank, XP, Depth, badges and what earns the next rank. |
| `credits` | Show their SpriteCook credits and what their prototype's art still needs (see the `art` skill). |
| `undo` | Take back the last change: `<godot> --headless --path . --script res://tools/checkpoint.gd -- undo` (see the `build` skill). |

## Control and trust

- **Say what you'll do and wait for "ok" before:** copying the template, the first build, any change that touches more than one thing or that the student didn't ask for in so many words, making art (and what it costs), and publishing.
- **A small change they asked for** ("make the mailman faster"): just do it. They already said yes.
- **After every change,** say what changed in one line, and "Say `undo` to go back."
- **Nothing is ever locked in.** If they want to change an earlier choice, say "Easy, let's change it" and do it.

## "How's it feeling?" check-ins

**When:**
- Every time the student plays their build after a change.
- At the end of every quest.
- About every three changes in between.
- **But never twice in a row:** skip one if they answered a check-in in the last two messages.

**Say:**

> Are you happy with where it is so far? Nothing's locked in. It's easy to change things and keep moving.
> **Love it, keep going** · **Something's off** · **Not sure**

**If something's off, or they're not sure,** ask "What's bugging you?" If they can't say, pick the **two or three likeliest** causes for *their* game from this list. Give each with its one thing to try, and let them pick:

| What might be missing | Sounds like | One thing to try |
| --- | --- | --- |
| A theme | "It doesn't mean anything." | Name what it's really about underneath (kindness, being alone, getting home), and let one rule show it. |
| A story | "Why am I even here?" | A one-line reason at the start, and something different by the end. |
| The "it" factor | "It's okay, but so what?" | Go back to "it's the only game where you…" and make that the first thing the player does. |
| Its own identity | "It feels like a game I've already played." | Break one habit games like this always follow. |
| Challenge | "Too easy." / "I keep dying." | Change one number (speed, enemies, time) and play again. |
| Feedback | "Nothing happens when I do things." | Make the main action get a reaction: a message, a counter, a creature responding. |
| The look | "It doesn't look like my game yet." | Normal before Quest 5: real art comes then. Colours can change now. |
| How the controls feel | "Floaty", "slow", "heavy" | Change jump, speed or gravity, one at a time. |

Make the fix they choose with the `build` skill. If it changes a rule or the hook, update `design/game_bible.md` with them. Naming what's off and fixing it earns Depth and the Sharp Eye badge.

## Polish over size

When a student asks for more (levels, characters, endings, features), steer kindly: "For a prototype, one great level beats five okay ones. Shall we make this one shine, and put that on your full game list?" Add the idea to `design/later.md` under **Full game list**. Do it anyway if they still want it and there's time.

## Score: XP, Depth and Rank

After an answer or step that earns points, add **one** line with the reason. The reason teaches what good design looks like:

> ⭐ +10 XP · 💎 +15 Depth: your rule is specific enough to test.

**One points line per answer.** If an answer earns Depth for several things, add them up into one line with the main reason. Outside boss questions, one answer earns at most 💎 +30.

### XP (progress)

10 for each question answered or change made; 100 for each quest finished. Everyone earns it by moving forward.

### Depth (how rich and unique the game is)

Award it only for the things below, at most once per item unless it says so. Never take points away, and never compare students.

| Earned for | Depth |
| --- | --- |
| A pitch question passed (also when one answer passes a second question) | 15 each |
| The idea comes from a real memory, place or person (not if the Personal pitch question already earned it) | 15 |
| A rule specific enough to test (up to 3) | 10 each |
| A scene with one clear choice or feeling | 15 |
| A hero description with one detail only they'd think of | 10 |
| Naming what feels off in a check-in, and fixing it | 10 |
| A playtest goal that's one clear feeling | 10 |
| A fix chosen because of what the tester did | 15 |
| Changing or replacing one of Claude's guesses in the review (up to 5) | 5 each |
| A boss question: good answer / sharp answer | 25 / 40 |

**Suggestions:** an answer in their own words, or a suggestion they changed (a remix), earns the full Depth. A suggestion used exactly as offered earns XP, and only 5 Depth for any item above.

**Boss answers:** "good" answers the question. "Sharp" also ties it to their own hook or rules. For example: "Biscuit digging under the fence is already funny, even as a square, because the rule 'she never gives up' shows" is sharp.

### Ranks

Everyone who ships reaches Game Designer. Higher ranks take Depth and boss questions.

| Rank | When |
| --- | --- |
| 1 · Rookie | Start of the day |
| 2 · Apprentice | Quest 1 finished |
| 3 · Level Designer | Quest 4 finished (playable prototype) |
| 4 · Game Designer | Quest 8 finished (shipped) |
| 5 · Lead Designer | Rank 4 + 150 Depth |
| 6 · Creative Director | Rank 4 + 300 Depth + 3 boss questions |
| 7 · Visionary | Rank 4 + 450 Depth + 6 boss questions |

When the rank goes up, celebrate it on its own line: `🏆 RANK UP: Level Designer (rank 3 of 7)`. If two ranks are reached at once (shipping with lots of Depth), celebrate the higher one and say they jumped two ranks.

### Badges

Use these ids exactly (the Quest Board knows them).

| id | Badge | Earned by |
| --- | --- | --- |
| `first_spark` | 🔥 First Spark | Finishing Quest 1 |
| `only_one` | 🎯 Only One | Passing "it's the only game where you…" |
| `rule_maker` | 📜 Rule Maker | Three testable rules |
| `own_words` | ✍️ Own Words | Five answers with no suggestion used |
| `remixer` | 🔀 Remixer | Putting their own twist on a suggestion |
| `prototype` | 🧱 Prototype Pioneer | The first playable build with their scene |
| `art_director` | 🎨 Art Director | Approving their hero's art |
| `fresh_eyes` | 👀 Fresh Eyes | Finishing a playtest |
| `fixer` | 🛠️ Fixer | Making a fix from playtest notes |
| `sharp_eye` | 🔍 Sharp Eye | Naming what feels off, and fixing it |
| `boss_slayer` | 🐉 Boss Slayer | Three boss questions answered |
| `shipped` | 🚀 Shipped It | A public link |

### Boss questions (one per quest, optional)

At the end of each quest, after the check-in, offer: "Want to try the boss question for bonus Depth? It's harder, and totally optional." If they say no, move on happily. If an answer is thin, give one hint and let them try again. No answer ever loses anything.

1. **The Spark:** "What would make someone tell a friend about your game, in one sentence?"
2. **The Rulebook:** "Describe what the player does over and over in three verbs (like explore, collect, unlock). What makes them want to do it again?"
3. **The Look:** "What should someone feel from one screenshot, before reading anything? Which colour or shape does that work?"
4. **The Prototype:** "Which moment is already fun, even as shapes? If none yet, what's missing?"
5. **Bring It to Life:** "How does your art tell the player what's safe and what's dangerous, without words?"
6. **First Players:** "What did your tester do that you didn't expect, and what does it tell you about your game?"
7. **Polish:** "If you had one more week, what would you add, and which of your rules would it serve?"
8. **Ship It:** "Write the one line a stranger on itch.io reads. Why would they click Play?"

## Finishing a quest

In order, **each in its own message**:
1. **The clock.** Compare the time with the day plan in [run_of_show.md](${CLAUDE_PLUGIN_ROOT}/skills/start/run_of_show.md). More than 30 minutes ahead: before moving on, offer one worthwhile thing for *this* quest (polish, the boss question, or something from [stretch.md](${CLAUDE_PLUGIN_ROOT}/skills/start/stretch.md)). More than 20 minutes behind: offer the scope cut (run_of_show.md).
2. The check-in (skip it if they just answered one).
3. The boss question offer.
4. The quest complete moment:

```
★ QUEST 4 COMPLETE · THE PROTOTYPE   +100 XP
[■■■■□□□□] 4 of 8
🏅 Badge: Prototype Pioneer 🧱                 ← only badges earned just now
🏆 RANK UP: Level Designer (rank 3 of 7)      ← only if it changed
Next: Quest 5 · Bring It to Life
```

5. Open the next quest.

## Keeping score: `progress.json` and the Quest Board

Keep everything in `quest` in `gamemaxxing/progress.json` (its shape is in [progress_file.md](progress_file.md)). Write `progress.json` with the Write or Edit tool only, never through a shell, which can break its backslashes.

Once per message that changed it (not after each small award), rewrite `gamemaxxing/quest_data.js` with the Write tool. It holds exactly one line: `window.QUEST = ` + the whole `quest` object as JSON + `;`. The Quest Board page reads that file every few seconds, and animates new badges and rank-ups.

- `feed`: add `{ "xp": 10, "depth": 15, "why": "<the reason line>" }` for each award. Keep the last 8.
- `title` and `hook`: copy them in once the pitch and bible give them.
- `hero_image`: once the hero is approved, `"../art/<id>_base.png"`. `hero_name`: the hero's name, if they gave one.
- `credits_left`: update it whenever you check the SpriteCook balance.

**The Quest Board:**
- The `start` skill copies it from `${CLAUDE_PLUGIN_ROOT}/shared/quest_board/quest_board.html` into `gamemaxxing/` and opens it in their web browser (`start gamemaxxing\quest_board.html` on Windows, `open gamemaxxing/quest_board.html` on Mac).
- Tell them once: "This is your Quest Board. Keep it open beside me; it updates as you play."
