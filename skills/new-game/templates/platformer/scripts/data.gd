## Loads the game's data files. Everything a student would change lives in these files:
## game.json (title, colours, numbers), story.json (conversations and choices),
## entities.json (characters, creatures, items) and level.txt (the map, drawn with letters).
extends RefCounted

var game: Dictionary = {}
var story: Dictionary = {}
var entities: Dictionary = {}
var level: PackedStringArray = PackedStringArray()
var errors: Array[String] = []     # problems reading the files (the test bot fails if there are any)

func load_all() -> void:
	errors.clear()
	game = _load("res://game.json")
	story = _load("res://story.json")
	entities = _load("res://entities.json")
	level = PackedStringArray()
	if FileAccess.file_exists("res://level.txt"):
		for line in FileAccess.get_file_as_string("res://level.txt").split("\n"):
			level.append(line.strip_edges(false, true))
		while level.size() > 0 and level[level.size() - 1] == "":
			level.remove_at(level.size() - 1)
	if errors.is_empty():
		_check()

## Catches mistakes that would quietly break the game: a conversation that doesn't exist,
## a level with uneven rows, a letter in the level that nothing uses.
func _check() -> void:
	var scenes: Dictionary = story.get("scenes", {})
	for id in entities:
		var e: Variant = entities[id]
		if not (e is Dictionary):
			continue
		var tk: Variant = e.get("talk", "")
		var names: Array = [tk] if tk is String else []
		if tk is Array:
			for entry in tk:
				if entry is Dictionary:
					names.append(str(entry.get("scene", "")))
		for n in names:
			if n != "" and not scenes.has(n):
				errors.append("entities.json: %s talks with a scene called '%s', but story.json has no scene with that name" % [id, n])
	for sid in scenes:
		var sc: Variant = scenes[sid]
		if not (sc is Dictionary):
			continue
		var nexts: Array = [str(sc.get("next", ""))]
		for o in sc.get("options", []):
			if o is Dictionary:
				nexts.append(str(o.get("next", "")))
		for n in nexts:
			if n != "" and not scenes.has(n):
				errors.append("story.json: scene '%s' goes next to '%s', which doesn't exist" % [sid, n])
	var start := str(game.get("start_scene", ""))
	if start != "" and not scenes.has(start):
		errors.append("game.json: start_scene '%s' isn't in story.json" % start)
	if level.size() > 0:
		var starts := 0
		for y in level.size():
			if level[y].length() != level[0].length():
				errors.append("level.txt: row %d is %d letters long, but row 1 is %d. Every row must be the same length" % [y + 1, level[y].length(), level[0].length()])
			for c in level[y]:
				if c == "P":
					starts += 1
				elif not (c in ["#", ".", " ", "~", "=", "^"]) and entity_for_char(c).is_empty():
					errors.append("level.txt: the letter '%s' on row %d isn't in entities.json" % [c, y + 1])
		if starts != 1:
			errors.append("level.txt needs exactly one P (where the player starts); it has %d" % starts)

func _load(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		errors.append("%s is missing" % path.get_file())
		return {}
	var j := JSON.new()
	if j.parse(FileAccess.get_file_as_string(path)) != OK or not (j.data is Dictionary):
		var msg := "%s has a mistake on line %d (%s). Check for a missing comma, quote or bracket." % [path.get_file(), j.get_error_line() + 1, j.get_error_message()]
		errors.append(msg)
		push_error(msg)
		return {}
	return j.data

static func read_json(path: String) -> Dictionary:
	if not FileAccess.file_exists(path):
		return {}
	var parsed: Variant = JSON.parse_string(FileAccess.get_file_as_string(path))
	return parsed if parsed is Dictionary else {}

## A colour from game.json "colours", or the fallback if it's missing.
func colour(key: String, fallback: String) -> Color:
	var cols: Dictionary = game.get("colours", {})
	return Color.from_string(str(cols.get(key, fallback)), Color.from_string(fallback, Color.WHITE))

## A number from a dictionary, with a default.
static func num(d: Dictionary, key: String, fallback: float) -> float:
	var v: Variant = d.get(key, fallback)
	if v is float or v is int:
		return float(v)
	return fallback

## The entity (character, creature, item...) drawn with this letter in level.txt.
func entity_for_char(c: String) -> Dictionary:
	for id in entities:
		var e: Variant = entities[id]
		if e is Dictionary and str(e.get("char", "")) == c:
			var out: Dictionary = e.duplicate()
			out["id"] = id
			return out
	return {}

func entity(id: String) -> Dictionary:
	var e: Variant = entities.get(id, {})
	if e is Dictionary:
		var out: Dictionary = e.duplicate()
		out["id"] = id
		return out
	return {}
