extends SceneTree
## Packs the web version of the game (build/web) into one zip file for itch.io.
## The zip has index.html at the top, which is what itch.io needs.
##   godot --headless --path . --script res://tools/zip_web.gd
## Writes build/<game-title>-web.zip and prints its name.

func _initialize() -> void:
	var src := "res://build/web/"
	if not FileAccess.file_exists(src + "index.html"):
		print("ZIP FAILED: build/web/index.html is missing. Export the game for the web first.")
		quit(1)
		return
	var title := "my-game"
	var g: Variant = JSON.parse_string(FileAccess.get_file_as_string("res://game.json"))
	if g is Dictionary and str(g.get("title", "")) != "":
		title = str(g["title"])
	var slug := ""
	for ch in title.to_lower():
		if (ch >= "a" and ch <= "z") or (ch >= "0" and ch <= "9"):
			slug += ch
		elif not slug.ends_with("-"):
			slug += "-"
	slug = slug.trim_prefix("-").trim_suffix("-")
	if slug == "":
		slug = "my-game"
	var out := "res://build/%s-web.zip" % slug
	var zip := ZIPPacker.new()
	if zip.open(ProjectSettings.globalize_path(out)) != OK:
		print("ZIP FAILED: couldn't create %s" % out)
		quit(1)
		return
	var count := 0
	for f in DirAccess.get_files_at(src):
		if f.ends_with(".import") or f.ends_with(".tmp"):
			continue
		zip.start_file(f)
		zip.write_file(FileAccess.get_file_as_bytes(src + f))
		zip.close_file()
		count += 1
	zip.close()
	print("ZIP DONE: build/%s-web.zip (%d files)" % [slug, count])
	quit(0)
