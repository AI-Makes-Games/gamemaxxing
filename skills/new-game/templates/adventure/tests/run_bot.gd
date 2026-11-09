extends SceneTree
## Plays the whole game with no window, from the title screen to an ending, like a player would:
## it picks things up, talks to everyone who has something new to say, fights what comes close,
## opens doors it can open, and walks to the goal. Prints "RUN COMPLETE: <ending>" when it works.
## Run:  godot --headless --path . --script res://tests/run_bot.gd
##       add  -- choice=1  to pick the second choice in conversations instead of the first.

const MAX_FRAMES := 15000
const STEPS_PER_FRAME := 4

var main: Node
var world: Node2D
var f := 0
var choice := 0
var phase := "title"
var end_frame := 0
var path: Array = []
var target_key := ""
var stuck := 0
var last_p := Vector2.ZERO
var ticks := 0
var last_token := -1
var token_tick := 0

func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("choice="):
			choice = int(a.substr(7))
	main = load("res://main.tscn").instantiate()
	root.add_child(main)

func _process(_d: float) -> bool:
	f += 1
	if f > MAX_FRAMES:
		_fail("ran out of time")
		return true
	match phase:
		"title":
			if main.D.errors.size() > 0:
				print("RUN FAILED: ", "; ".join(main.D.errors))
				quit(1)
				return true
			if main.screen_name == "title" and f > 3:
				main.start_game()
				phase = "play"
		"play":
			world = main.world
			if world == null or not world.is_inside_tree():
				return false
			world.bot = true
			for i in STEPS_PER_FRAME:
				if world.done or phase != "play":
					break
				_steer()
				world.tick(1.0 / 60.0)
			if world.done:
				phase = "ending_wait"
		"ending_wait":
			if main.screen_name == "ending":
				print("RUN COMPLETE: ", main.ending_id)
				end_frame = f
				phase = "ending"
		"ending":
			if f - end_frame > 3:
				main.show_title()
				phase = "back"
		"back":
			if main.screen_name == "title":
				quit(0)
				return true
	return false

func _fail(why: String) -> void:
	if phase == "failed":
		return
	phase = "failed"
	var p: Vector2 = world.player.p if world != null else Vector2.ZERO
	print("RUN FAILED: %s (frame %d, player at tile %s, target %s)" % [why, f, str(world.tile_of(p)) if world != null else "-", target_key])
	quit(1)

# ---------- deciding what to do ----------
func _steer() -> void:
	world.ctrl.move = Vector2.ZERO
	if world.is_talking():
		var n: int = world.talking.opts.size() if world.talking.phase == "text" else 0
		world.choose(min(choice, n - 1) if n > 0 else 0)
		return
	var p: Vector2 = world.player.p
	# making progress? (picking things up, new conversations, doors) if not for a minute, stop early
	var token: int = world.story.items.size() + world.last_scene.size() * 10 + world.doors.filter(func(d): return d.open).size() * 100 + world.story.log.size() * 1000
	if token != last_token:
		last_token = token
		token_tick = ticks
	elif ticks - token_tick > 3600:
		_fail("no progress for a minute of play (stuck, or blocked by a creature)")
		return
	ticks += 1
	# fight anything close, or keep away from it when the game has no fighting
	var avoid := Vector2.ZERO
	for e in world.enemies:
		if e.dead or e.p.distance_to(p) > 70:
			continue
		if world.can_attack():
			world.player.face = (e.p - p).normalized()
			world.ctrl.move = (e.p - p).normalized() * (0.3 if e.p.distance_to(p) > 30 else 0.0)
			world.ctrl.action = true
			return
		avoid += (p - e.p).normalized() * (70.0 - e.p.distance_to(p)) / 70.0
	var tgt := _pick_target()
	if tgt.is_empty():
		_fail("nothing left to do, and no ending reached")
		return
	if tgt.key != target_key:
		target_key = tgt.key
		path = []
	if tgt.has("talk") and tgt.p.distance_to(p) < 44:
		world.talk(tgt.talk)
		return
	if tgt.has("door") and tgt.p.distance_to(p) < 44:
		world.ctrl.interact = true
		return
	var gentle: bool = not world.can_attack()
	if path.is_empty() or f % (8 if gentle else 30) == 0:
		path = []
		if gentle:
			path = _bfs(world.tile_of(p), world.tile_of(tgt.p), tgt.has("door"), true)   # around the creatures
		if path.is_empty():
			path = _bfs(world.tile_of(p), world.tile_of(tgt.p), tgt.has("door"))
	while path.size() > 0 and (Vector2(path[0]) * world.ts + Vector2.ONE * world.ts / 2.0).distance_to(p) < 6:
		path.pop_front()
	var next: Vector2 = tgt.p if path.is_empty() else Vector2(path[0]) * world.ts + Vector2.ONE * world.ts / 2.0
	world.ctrl.move = ((next - p).normalized() + avoid * 1.6).normalized()
	# unstick: wiggle sideways if not moving
	if p.distance_to(last_p) < 0.2:
		stuck += 1
		if stuck > 20:
			world.ctrl.move = world.ctrl.move.orthogonal() * (1 if (f / 40) % 2 == 0 else -1)
	else:
		stuck = 0
	last_p = p

## What to go for next: things to pick up, then anyone with something new to say,
## then doors that can be opened, then the goal. Only targets that can be reached count.
func _pick_target() -> Dictionary:
	var here: Vector2i = world.tile_of(world.player.p)
	var cands: Array = []
	for it in world.items:
		if not it.taken:
			cands.append({"key": "item:" + it.id, "p": it.p})
	for n in world.npcs:
		var sid: String = world.npc_scene(n)
		if sid != "" and world.last_scene.get(n.id, "") != sid:
			cands.append({"key": "npc:%s:%s" % [n.id, sid], "p": n.p, "talk": n})
	for d in world.doors:
		if not d.open and world.can_open(d):
			cands.append({"key": "door:" + d.id, "p": d.p, "door": d})
	for g in world.goals:
		cands.append({"key": "goal", "p": g.p})
	for c in cands:
		if c.p.distance_to(world.player.p) < 40 or not _bfs(here, world.tile_of(c.p), c.has("door")).is_empty():
			return c
	return {}

func _near_creature(t: Vector2i) -> bool:
	var ts: float = world.ts
	var c: Vector2 = Vector2(t) * ts + Vector2.ONE * ts / 2.0
	for e in world.enemies:
		if not e.dead and e.p.distance_to(c) < ts * 1.6:
			return true
	return false

func _bfs(from: Vector2i, to: Vector2i, allow_target_solid: bool, avoid_creatures := false) -> Array:
	if from == to:
		return []
	var prev := {from: from}
	var q: Array = [from]
	while q.size() > 0:
		var cur: Vector2i = q.pop_front()
		for d in [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]:
			var nx: Vector2i = cur + d
			if prev.has(nx):
				continue
			if world.solid(nx.x, nx.y) and not (allow_target_solid and nx == to):
				continue
			if avoid_creatures and nx != to and _near_creature(nx):
				continue
			prev[nx] = cur
			if nx == to:
				var out: Array = []
				var s: Vector2i = nx
				while s != from:
					out.push_front(s)
					s = prev[s]
				return out
			q.append(nx)
	return []
