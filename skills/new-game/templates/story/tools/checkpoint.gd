extends SceneTree
## Save points for the game, so any change can be undone. No Git needed.
## A checkpoint is a copy of the game's data files and scripts in gamemaxxing/checkpoints/<time>/.
##   godot --headless --path . --script res://tools/checkpoint.gd -- save-tested "added a cat"
##        (runs the test bot; only if the game passes, saves a checkpoint marked as working. Use this after every change.)
##   godot --headless --path . --script res://tools/checkpoint.gd -- save "before adding a boss"   (saves without testing)
##   godot --headless --path . --script res://tools/checkpoint.gd -- restore    (go back to the newest one that passed)
##   godot --headless --path . --script res://tools/checkpoint.gd -- restore <name>
##   godot --headless --path . --script res://tools/checkpoint.gd -- undo
##        (the student's "undo": throws away an unsaved change, or else goes back one working checkpoint
##         and marks the one it left as undone, so restore and the next undo never bring it back)
##   godot --headless --path . --script res://tools/checkpoint.gd -- list

const ROOT := "res://gamemaxxing/checkpoints/"
const FILES := ["game.json", "story.json", "entities.json", "level.txt", "art_bible.json", "project.godot", "main.tscn"]
const FOLDERS := ["scripts", "tests", "tools"]

func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	var cmd := args[0] if args.size() > 0 else "list"
	DirAccess.make_dir_recursive_absolute(ROOT)
	# keep Godot from treating the copies as part of the game
	if not FileAccess.file_exists("res://gamemaxxing/.gdignore"):
		FileAccess.open("res://gamemaxxing/.gdignore", FileAccess.WRITE).close()
	match cmd:
		"save":
			_save(" ".join(args.slice(1)) if args.size() > 1 else "checkpoint", false)
		"save-tested":
			_save_tested(" ".join(args.slice(1)) if args.size() > 1 else "checkpoint")
		"passed":
			_mark_passed()
		"restore":
			_restore(args[1] if args.size() > 1 else "")
		"undo":
			_undo()
		_:
			_list()
	quit()

func _names() -> Array:
	var out := Array(DirAccess.get_directories_at(ROOT))
	out.sort()
	return out

func _info(name: String) -> Dictionary:
	var v: Variant = JSON.parse_string(FileAccess.get_file_as_string(ROOT + name + "/info.json"))
	return v if v is Dictionary else {}

func _copy(from_dir: String, to_dir: String, rel: String) -> void:
	if FileAccess.file_exists(from_dir + rel):
		DirAccess.make_dir_recursive_absolute((to_dir + rel).get_base_dir())
		DirAccess.copy_absolute(from_dir + rel, to_dir + rel)
	elif DirAccess.dir_exists_absolute(from_dir + rel):
		for f in DirAccess.get_files_at(from_dir + rel):
			if not f.ends_with(".uid"):
				_copy(from_dir, to_dir, rel + "/" + f)
		for d in DirAccess.get_directories_at(from_dir + rel):
			_copy(from_dir, to_dir, rel + "/" + d)

## Runs the game's test bot; saves a working checkpoint only if it prints RUN COMPLETE.
func _save_tested(label: String) -> void:
	var out: Array = []
	var code := OS.execute(OS.get_executable_path(), ["--headless", "--path", ProjectSettings.globalize_path("res://"), "--script", "res://tests/run_bot.gd"], out, true)
	var text := "\n".join(out)
	var result := ""
	for line in text.split("\n"):
		if line.begins_with("RUN COMPLETE") or line.begins_with("RUN FAILED"):
			result = line.strip_edges()
	if code == 0 and result.begins_with("RUN COMPLETE"):
		print(result)
		_save(label, true)
	else:
		print(result if result != "" else "RUN FAILED: the test bot didn't finish (exit code %d)" % code)
		print("NOT SAVED: the game doesn't pass yet, so no checkpoint was made.")

func _save(label: String, passed: bool) -> void:
	var name := Time.get_datetime_string_from_system().replace(":", "").replace("-", "").replace("T", "-")
	# never overwrite: two saves in the same second get -2, -3...
	var base := name
	var n := 2
	while DirAccess.dir_exists_absolute(ROOT + name):
		name = "%s-%d" % [base, n]
		n += 1
	var dest := ROOT + name + "/"
	DirAccess.make_dir_recursive_absolute(dest)
	for f in FILES + FOLDERS:
		_copy("res://", dest, f)
	var info := {"label": label, "time": Time.get_datetime_string_from_system(), "passed_bot": passed}
	var fa := FileAccess.open(dest + "info.json", FileAccess.WRITE)
	fa.store_string(JSON.stringify(info, "  "))
	fa.close()
	print("CHECKPOINT SAVED: %s (%s)%s" % [name, label, ", marked as working" if passed else ""])

func _mark_passed() -> void:
	var names := _names()
	if names.is_empty():
		print("No checkpoints yet.")
		return
	var name: String = names[names.size() - 1]
	var info := _info(name)
	info["passed_bot"] = true
	var fa := FileAccess.open(ROOT + name + "/info.json", FileAccess.WRITE)
	fa.store_string(JSON.stringify(info, "  "))
	fa.close()
	print("CHECKPOINT PASSED: %s" % name)

func _working(name: String) -> bool:
	var info := _info(name)
	return bool(info.get("passed_bot", false)) and not bool(info.get("undone", false))

## Working checkpoints, newest first.
func _working_names() -> Array:
	var out: Array = []
	var names := _names()
	for i in range(names.size() - 1, -1, -1):
		if _working(names[i]):
			out.append(names[i])
	return out

func _same_bytes(a: String, b: String) -> bool:
	if FileAccess.file_exists(a) != FileAccess.file_exists(b):
		return false
	if not FileAccess.file_exists(a):
		return true
	return FileAccess.get_file_as_bytes(a) == FileAccess.get_file_as_bytes(b)

## True when the game's files match the checkpoint (only the files a checkpoint keeps).
func _matches(name: String) -> bool:
	var cp := ROOT + name + "/"
	for f in FILES:
		if not _same_bytes("res://" + f, cp + f):
			return false
	for d in FOLDERS:
		if not _same_folder("res://" + d, cp + d):
			return false
	return true

func _same_folder(a: String, b: String) -> bool:
	if DirAccess.dir_exists_absolute(a) != DirAccess.dir_exists_absolute(b):
		return false
	if not DirAccess.dir_exists_absolute(a):
		return true
	var fa: Array = Array(DirAccess.get_files_at(a)).filter(func(x): return not x.ends_with(".uid"))
	var fb: Array = Array(DirAccess.get_files_at(b)).filter(func(x): return not x.ends_with(".uid"))
	fa.sort()
	fb.sort()
	if fa != fb:
		return false
	for f in fa:
		if not _same_bytes(a + "/" + f, b + "/" + f):
			return false
	for d in DirAccess.get_directories_at(a):
		if not _same_folder(a + "/" + d, b + "/" + d):
			return false
	return true

func _set_info(name: String, key: String, value: Variant) -> void:
	var info := _info(name)
	info[key] = value
	var fa := FileAccess.open(ROOT + name + "/info.json", FileAccess.WRITE)
	fa.store_string(JSON.stringify(info, "  "))
	fa.close()

func _undo() -> void:
	var working := _working_names()
	if working.is_empty():
		print("UNDO FAILED: no working checkpoint to go back to.")
		return
	var newest: String = working[0]
	if not _matches(newest):
		# an unsaved (or failed) change: throw it away
		_restore(newest)
		print("UNDONE: threw away the change that wasn't saved; back to \"%s\"." % str(_info(newest).get("label", "")))
		return
	if working.size() < 2:
		print("UNDO FAILED: this is the first working version, so there's nothing earlier to go back to.")
		return
	_set_info(newest, "undone", true)
	_restore(working[1])
	print("UNDONE: \"%s\". Back to \"%s\"." % [str(_info(newest).get("label", "")), str(_info(working[1]).get("label", ""))])

func _restore(name: String) -> void:
	var names := _names()
	if name == "":
		var working := _working_names()
		if not working.is_empty():
			name = working[0]
	if name == "" or not DirAccess.dir_exists_absolute(ROOT + name):
		print("RESTORE FAILED: no checkpoint to go back to.")
		return
	for f in FILES + FOLDERS:
		_copy(ROOT + name + "/", "res://", f)
	print("CHECKPOINT RESTORED: %s (%s)" % [name, str(_info(name).get("label", ""))])

func _list() -> void:
	for n in _names():
		var info := _info(n)
		var state := "undone" if info.get("undone", false) else ("passed" if info.get("passed_bot", false) else "      ")
		print("%s  %s  %s" % [n, state, info.get("label", "")])
