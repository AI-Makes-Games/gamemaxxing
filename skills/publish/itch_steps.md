# Putting the game on itch.io (the student clicks, Claude guides)

Give one step at a time. Wait for "done" before the next.

1. **Make a free account** (skip if they have one). Go to **itch.io** and click **Register** at the top right. Choose a username: it becomes part of your game's web address.
1b. **Confirm your email:** open the email itch.io just sent you and click the link in it. (It can take a minute to arrive.)
2. **Start a new project.** Logged in, click the **arrow next to your username** (top right), then **Upload new project**.
3. **Title:** type your game's title. Itch.io makes the **Project URL** from it; you can change it.
4. **Short description or tagline:** your hook, for example "It's the only game where you...".
5. **Classification:** leave it on **Games**.
6. **Kind of project:** choose **HTML** (it may be called **HTML Game**). *This is the important one: without it, the game won't play in the browser.*
7. **Release status:** choose **Released** (or **In development** if you plan to keep working on it).
8. **Pricing:** choose **No payments**.
9. **Uploads:** click **Upload files**. A window opens to choose a file. Claude gives you the zip's full address (for example `C:\Users\you\MyGame\build\my-game-web.zip`): paste it into the **File name** box at the bottom of that window and press Enter. Wait for the upload to finish.
10. Under the uploaded file, tick **This file will be played in the browser**.
11. **Embed options** (just below):
    - Choose **Embed in page**.
    - **Viewport dimensions:** width **1280**, height **720** (or the size Claude tells you).
    - Tick **Fullscreen button**.
    - Leave the other boxes as they are.
12. **Details** (optional): pick a **Genre**, add a few **Tags**, and a longer **Description** if you like.
13. **Visibility & access:** choose **Draft** for now, then click **Save & view page** at the bottom.
14. **Test it:** on your page, click **Run game** and play for a minute.
15. **Make it public:** click **Edit game** (top of the page), change **Visibility & access** to **Public**, and click **Save**. Copy the address from your browser's address bar: that's your game's link.

## If the game doesn't play on itch.io

| What you see | Fix |
| --- | --- |
| A download button instead of a game | Edit game: set **Kind of project** to **HTML** and tick **This file will be played in the browser**. |
| "index.html not found" | Upload the zip made by Claude (it has `index.html` at the top), not the `build/web` folder or a zip of it. |
| A black or grey box that never loads | Give it 20 seconds the first time. If still stuck, try another browser (Chrome or Edge work best), and check the zip is the latest one. |
| The game is cut off or tiny | Edit game: set the viewport to 1280 by 720 and tick Fullscreen button. |
| Keys don't work | Click once on the game first, so it has the keyboard. |
