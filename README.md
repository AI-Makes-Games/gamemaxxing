# GameMaxxing

Make your own 2D game in one day, then share it on the web. You don't need to know how to code. A friendly coach in Claude walks you through every step: your idea, your rules, your art, playtesting with other people, and publishing.

## What you need

- A Windows or Mac laptop
- The Claude desktop app, signed in with Claude Pro (your workshop has arranged this for you)
- A SpriteCook account for your game's art (also arranged by your workshop)
- Godot 4.7, a free game maker

## Set up (about 15 minutes)

1. **Install Godot 4.7.** Download the standard version (not ".NET") from godotengine.org. Open it once, then click **Editor → Manage Export Templates → Download and Install**. This lets your game run in a web browser.
2. **Install the Claude desktop app** and sign in.
3. **Make a folder for your game.** Make an empty folder called `MyGame` (on your Desktop is fine). In the Claude app, open the **Code** tab and choose that folder.
4. **Add GameMaxxing.** In the Code tab, click **Customize** in the sidebar, add a marketplace with this address, then install **gamemaxxing** from the list:
   ```
   https://github.com/AI-Makes-Games/gamemaxxing
   ```
   Or type these two lines into Claude Code, one at a time:
   ```
   /plugin marketplace add AI-Makes-Games/gamemaxxing
   /plugin install gamemaxxing@gamemaxxing
   ```
5. **Add SpriteCook** the same way (address `https://github.com/SpriteCook/claude-plugin`, then install **spritecook**), and sign in to SpriteCook when it asks. Or type:
   ```
   /plugin marketplace add SpriteCook/claude-plugin
   /plugin install spritecook@spritecook
   ```
6. **Start your game.** In your `MyGame` folder in the Code tab, type:
   ```
   /gamemaxxing:start
   ```

If you ever get lost, type `/gamemaxxing:start` again. It always picks up where you left off.

## Your game, your ideas

The coach never writes your game's idea, rules or story for you. It asks questions and tidies your words. Any time Claude has to guess something (a name, a number, a colour), it writes it down so you can keep it or change it later.

## For workshop leaders

- **Made for:** Godot 4.7 (GL Compatibility, single-threaded web export), Windows and Mac. No Python, Node or Git needed on students' laptops.
- **Three game templates:** adventure (top-down), platformer (side view) and story (choices). Each one plays from title to ending with placeholder shapes, and swaps in SpriteCook pixel art when it arrives. Each has a test bot that plays it through after every change.
- **The day:** `/gamemaxxing:start` runs the whole schedule (pitch, game bible, build, art, two playtests, publish to itch.io). `/gamemaxxing:coach` gives the leader a one-screen view of where a student is.
- **Accounts:** each student needs their own Claude Pro, SpriteCook and itch.io account. A full adventure game uses about 470 SpriteCook credits.
- **Licence:** MIT (see `LICENSE`).
