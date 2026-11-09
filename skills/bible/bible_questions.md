# The five inputs

Ask one at a time, in this order.

| Input | Ask | Counts when | Saved to |
| --- | --- | --- | --- |
| Hook | "Finish this: it's the only game where you ___." | Something the player does or feels (it usually comes from the pitch) | `game_bible.md`, and the title screen tagline |
| Main action | "What does the player do most, with their hands? Walk and explore, run and jump, or read and choose?" | One main action | `game_bible.md`; picks the template |
| Rules | "Give me 3 to 5 things your game **always** or **never** does." | Each rule can be checked against a change ("Nobody ever dies", "The lights always go out at midnight") | `game_bible.md`; the `build` skill checks every change against them |
| One scene | "Let's write one moment from your game in your own words. A few sentences is plenty." Then the three questions below | Says where, who, and what the player must decide | `game_bible.md`; becomes the core of the game's story data |
| The look | "Your game will be in pixel art, like classic games, in your colours. Show me or describe 3 pictures you love the look of (screenshots, photos, paintings, anything), then give me 3 words for how it should feel to look at." Then, as a separate message: "And your hero: who are they, and what do they look like? A few words is plenty." | 3 pictures (pasted or described), 3 words, and a few words about the hero | `art_bible.json` |

If their pictures are in another style (watercolour, photos), say the pixel art will borrow their colours and mood. Don't promise the same technique.

## The scene: three questions, one at a time

1. "**Where** are we, and what does it feel like to be there?"
2. "**Who** is there with the player?"
3. "What does the player have to **decide**, and what makes it hard?"

Stitch the answers into a short scene using their words. Read it back. Never invent the decision or the people.

## Template from the main action

| They do most | Template | Why, in one line to the student |
| --- | --- | --- |
| Walking, exploring, talking, fighting | `adventure` | "A top-down game where you walk around, talk to people and face enemies." |
| Running, jumping, timing | `platformer` | "A side-on game about running and jumping." |
| Reading, choosing, deciding | `story` | "A story game where every choice changes what happens." |

If it's a mix, pick by what they'd do most in the first minute of play, and say so.

## What the templates can do (check the student's rules against this)

| Template | Can do | Can't do (yet) |
| --- | --- | --- |
| All | conversations with choices; flags and counters that change words and endings; 2 or more endings; picking up items | sound or music; saving progress between plays |
| Adventure | walking in four directions; talking; creatures that wander, chase or keep away; swinging at them, **or no fighting at all** (being caught sends you back); locked doors and keys; checkpoints | running; jumping; timers on screen |
| Platformer | running, jumping, one-way platforms, spikes, creatures you can jump on, collectibles, checkpoints, a secret ending; talking to people and signs | a countdown or clock on screen; water to swim in; climbing |
| Story | backgrounds, two portraits per scene, 1 to 4 choices, an optional countdown on a choice | moving around; different faces for the same character |

## Examples to offer only when they're stuck

- **Rules:** "Nobody ever dies, they just go home." "You can never go back the way you came." "The music always tells you when danger is near."
- **Main action:** "Mostly you sneak around and talk your way past people." "Mostly you jump between rooftops."
- **3 words:** "cosy, misty, warm", "neon, rainy, lonely", "bright, bouncy, silly".

## `design/game_bible.md` format

```markdown
# Game bible: <working title>

## Hook
It's the only game where you <...>.

## Main action
<their words>. Template: <adventure | platformer | story>.

## Rules
1. Always/Never <...>
2. ...

## Ending feeling
<one feeling, from the pitch or the bible>

## What gets in the way
<their answer> (adventure and platformer)

## One scene (in my own words)
<the stitched scene>

## The look
- Pictures: <short description of each, or "pasted image 1: ...">
- Words: <word>, <word>, <word>
```
