extends SceneTree
## Turns downloaded animation strips into a Godot animation set the game can show.
##   art/<id>/<id>_<animation>.png   a horizontal strip of square frames (from SpriteCook)
##   art/<id>/meta.json (optional)   {"fps": {"walk": 10}, "frame_size": {"attack": [80, 80]}}
## Writes art/<id>/<id>_frames.tres. One-shot animations (attack, hurt, death...) don't loop.
## Run:  godot --headless --path . --script res://tools/build_frames.gd -- hero
##       godot --headless --path . --script res://tools/build_frames.gd -- --all
## Then: godot --headless --path . --import      (so the game can load the new pictures)

const ONE_SHOT := ["attack", "throw", "punch", "skill", "hurt", "death", "die", "windup", "dodge", "jump_start", "land"]

func _initialize() -> void:
	var ids: Array = Array(OS.get_cmdline_user_args())
	if ids == ["--all"]:
		ids = Array(DirAccess.get_directories_at("res://art"))
	if ids.is_empty():
		print("Usage: godot --headless --path . --script res://tools/build_frames.gd -- <id> [<id> ...] | --all")
		quit(1)
		return
	var ok := true
	for id in ids:
		ok = build(str(id)) and ok
	quit(0 if ok else 1)

func build(id: String) -> bool:
	var folder := "res://art/%s/" % id
	if not DirAccess.dir_exists_absolute(folder):
		print("%s: no folder art/%s" % [id, id])
		return false
	var meta := {}
	if FileAccess.file_exists(folder + "meta.json"):
		var m: Variant = JSON.parse_string(FileAccess.get_file_as_string(folder + "meta.json"))
		if m is Dictionary:
			meta = m
	var files: Array = []
	for fn in DirAccess.get_files_at(folder):
		if fn.begins_with(id + "_") and fn.ends_with(".png"):
			files.append(fn)
	files.sort()
	if files.is_empty():
		print("%s: no strips found (expected art/%s/%s_<animation>.png)" % [id, id, id])
		return false
	var ext: Array[String] = []
	var sub: Array[String] = []
	var anims: Array[String] = []
	for i in files.size():
		var fn: String = files[i]
		var anim := fn.substr(id.length() + 1, fn.length() - id.length() - 5)
		var img := Image.load_from_file(ProjectSettings.globalize_path(folder + fn))
		if img == null:
			print("%s: couldn't read %s" % [id, fn])
			return false
		var w := img.get_width()
		var h := img.get_height()
		var fs: Variant = (meta.get("frame_size", {}) as Dictionary).get(anim, [h, h])
		var fw := int(fs[0])
		var fh := int(fs[1])
		var n: int = max(1, w / fw)
		if n * fw != w:
			print("warning: %s is %d wide, which isn't a whole number of %d-wide frames" % [fn, w, fw])
		ext.append('[ext_resource type="Texture2D" path="res://art/%s/%s" id="t%d"]' % [id, fn, i])
		var frames: Array[String] = []
		for k in n:
			var sid := "a%d_%d" % [i, k]
			sub.append('[sub_resource type="AtlasTexture" id="%s"]\natlas = ExtResource("t%d")\nregion = Rect2(%d, 0, %d, %d)' % [sid, i, k * fw, fw, fh])
			frames.append('{"duration": 1.0, "texture": SubResource("%s")}' % sid)
		var fps := float((meta.get("fps", {}) as Dictionary).get(anim, 8))
		var loop := "false" if anim in ONE_SHOT else "true"
		anims.append('{"frames": [%s], "loop": %s, "name": &"%s", "speed": %.1f}' % [", ".join(frames), loop, anim, fps])
	var out := '[gd_resource type="SpriteFrames" load_steps=%d format=3]\n\n' % (ext.size() + sub.size() + 1)
	out += "\n".join(ext) + "\n\n" + "\n\n".join(sub) + "\n\n[resource]\nanimations = [" + ", ".join(anims) + "]\n"
	var f := FileAccess.open(folder + "%s_frames.tres" % id, FileAccess.WRITE)
	f.store_string(out)
	f.close()
	print("%s: %d animations -> art/%s/%s_frames.tres" % [id, files.size(), id, id])
	return true
