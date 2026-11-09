## Finds the art for a character. If art/<id>/<id>_frames.tres exists (made by tools/build_frames.gd),
## the character shows that animation. If not, the game draws a simple placeholder shape instead,
## so the game always works, with or without art.
extends RefCounted

static var _cache := {}

static func frames(id: String) -> SpriteFrames:
	if id == "":
		return null
	if _cache.has(id):
		return _cache[id]
	var path := "res://art/%s/%s_frames.tres" % [id, id]
	var f: SpriteFrames = null
	if ResourceLoader.exists(path):
		var r: Resource = load(path)
		if r is SpriteFrames:
			f = r
	_cache[id] = f
	return f

## Picks the best animation for what the character is doing. Missing animations fall back to idle.
static func pick(f: SpriteFrames, state: String) -> String:
	var wants := {
		"idle": ["idle", "idle_right", "stand"],
		"walk": ["walk", "walk_right", "run", "move"],
		"run": ["run", "walk", "walk_right", "move"],
		"jump": ["jump", "fall", "idle"],
		"fall": ["fall", "jump", "idle"],
		"attack": ["attack", "punch", "swing"],
		"hurt": ["hurt", "hit"],
		"talk": ["talk", "idle"],
	}
	for name in wants.get(state, [state]):
		if f.has_animation(name):
			return name
	if f.has_animation("idle"):
		return "idle"
	var names := f.get_animation_names()
	return names[0] if names.size() > 0 else "default"
