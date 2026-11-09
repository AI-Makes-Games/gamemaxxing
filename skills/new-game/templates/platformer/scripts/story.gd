## Runs conversations and choices from story.json, and remembers what the player has done.
## Flags are facts that are true or false ("met_ada"), counters are numbers ("kindness"),
## items are the things the player carries. Conditions in story.json check these.
extends RefCounted

var scenes: Dictionary = {}
var flags: Dictionary = {}
var items: Dictionary = {}          # item id -> name shown to the player
var log: Array[String] = []         # what the player did, shown on the ending screen

func setup(story: Dictionary) -> void:
	scenes = story.get("scenes", {})
	var start: Variant = story.get("start_flags", {})
	if start is Dictionary:
		flags = start.duplicate()

## Conditions look like: "met_ada", "!met_ada", "has:key", "kindness>=2", "mood=angry".
## Join several with "&" when they must all be true: "met_ada & has:key".
func cond(c: Variant) -> bool:
	var s := "" if c == null else str(c).strip_edges()
	if s == "":
		return true
	for part in s.split("&"):
		if not _atom(part.strip_edges()):
			return false
	return true

func _atom(a: String) -> bool:
	var neg := a.begins_with("!")
	if neg:
		a = a.substr(1).strip_edges()
	var v := false
	if a.begins_with("has:"):
		v = items.has(a.substr(4).strip_edges())
	else:
		var matched := false
		for op in [">=", "<=", "!=", ">", "<", "="]:
			var i := a.find(op)
			if i > 0:
				v = _compare(flags.get(a.substr(0, i).strip_edges(), 0), op, a.substr(i + op.length()).strip_edges())
				matched = true
				break
		if not matched:
			v = truthy(flags.get(a, false))
	return v != neg

static func truthy(v: Variant) -> bool:
	if v is bool:
		return v
	if v is int or v is float:
		return v != 0
	return str(v) != "" and str(v) != "false"

func _compare(lhs: Variant, op: String, rhs: String) -> bool:
	if rhs.is_valid_float():
		var l := float(lhs) if (lhs is int or lhs is float) else 0.0
		var r := float(rhs)
		match op:
			">=": return l >= r
			"<=": return l <= r
			">": return l > r
			"<": return l < r
			"!=": return l != r
		return l == r
	if op == "!=":
		return str(lhs) != rhs
	return str(lhs) == rhs

## The text of a scene. Each line is either plain text, or {"if": ..., "t": ..., "else": ...}.
func text_of(scene: Dictionary) -> String:
	var out: Array[String] = []
	var lines: Variant = scene.get("text", [])
	if lines is String:
		lines = [lines]
	for seg in lines:
		var t := ""
		if seg is String:
			t = seg
		elif seg is Dictionary:
			t = str(seg.get("t", "")) if cond(seg.get("if", "")) else str(seg.get("else", ""))
		if t != "":
			out.append(t)
	return "\n\n".join(out)

## The choices the player can see right now (choices with an "if" that isn't true are hidden).
func options_of(scene: Dictionary) -> Array:
	var out: Array = []
	for o in scene.get("options", []):
		if o is Dictionary and cond(o.get("if", "")):
			out.append(o)
	return out

## Called when a scene is shown: applies its "set" and "add".
func enter(scene: Dictionary) -> void:
	apply(scene)

## Applies a scene's or a choice's effects: "set" flags, "add" to counters, "give" or "take" items.
func apply(d: Dictionary, item_names: Dictionary = {}) -> void:
	var s: Variant = d.get("set", {})
	if s is Dictionary:
		for k in s:
			flags[k] = s[k]
	var a: Variant = d.get("add", {})
	if a is Dictionary:
		for k in a:
			var cur: Variant = flags.get(k, 0)
			flags[k] = (float(cur) if (cur is int or cur is float) else 0.0) + float(a[k])
	if d.has("give"):
		var id := str(d["give"])
		items[id] = str(item_names.get(id, id))
	if d.has("take"):
		items.erase(str(d["take"]))
	if d.has("log"):
		log.append(str(d["log"]))

func note(line: String) -> void:
	if not log.has(line):
		log.append(line)
