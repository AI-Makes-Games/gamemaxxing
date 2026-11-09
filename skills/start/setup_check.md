# Setup check

Do these yourself. Only talk to the student about a check that fails, and then give one clear step at a time.

## 1. The folder

The current folder must be the student's game folder, and you must be able to write in it. Create `gamemaxxing/` and write `progress.json` there. If the folder already holds unrelated files (not a GameMaxxing game), suggest they make a new empty folder called `MyGame` and open Claude Code there.

## 2. Godot 4.7

Find the Godot program. Try in this order and stop at the first that works:

1. `godot --version` (it's on the PATH).
2. **Windows:** look for **files** (not folders) named `Godot_v4.7*.exe` in the Downloads folder, the Desktop, `C:\Program Files\Godot*` and `C:\Godot*`, including one folder down. Windows unzips Godot into a *folder* with the same name as the program, so check you've found the file.
3. **Mac:** `/Applications/Godot.app/Contents/MacOS/Godot`, then `~/Applications/Godot.app/Contents/MacOS/Godot`, then the Downloads folder.

Run it with `--version`. It must start with `4.7`.

- **Found, 4.7:** save two paths.
  - `godot_path`: the one for tests and tools. On Windows, the `..._console.exe` next to it, because it prints output.
  - `godot_play`: the one for opening the game for the student. On Windows, the normal `.exe`; the console one opens an extra black window. On Mac both are the same.
- **Found, wrong version:** tell them they need Godot 4.7 and where to get it (godotengine.org, standard version, not ".NET").
- **Not found:** ask them where they put Godot, or walk them through downloading it. Don't search the whole computer.

The web export templates must also be installed (they're needed at the end of the day). Look for a folder starting with `4.7` inside the export templates folder:

- **Windows:** `%APPDATA%\Godot\export_templates\`
- **Mac:** `~/Library/Application Support/Godot/export_templates/`

If it's missing, tell them: open Godot, click **Editor → Manage Export Templates → Download and Install**, and wait for it to finish. They can keep going while it downloads.

## 3. SpriteCook

Call SpriteCook's `get_credit_balance` tool.

- **Works:** set `spritecook` to `true` and say nothing unless the balance is under 450 credits (then tell Hex in `notes`).
- **Tool missing:** tell them, in plain words, to type these two lines in Claude Code, then sign in to SpriteCook when it asks:
  ```
  /plugin marketplace add SpriteCook/claude-plugin
  /plugin install spritecook@spritecook
  ```
  They can carry on without it for now. The game works with simple shapes until the art arrives.
