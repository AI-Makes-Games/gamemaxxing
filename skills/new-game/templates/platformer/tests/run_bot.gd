extends SceneTree
## Plays the whole game with no window, from the title screen to an ending, like a player would:
## it runs toward the goal, talks to anyone with something new to say, and before every jump
## (or step off an edge) it checks, using the game's own physics, that it will land safely.
## Prints "RUN COMPLETE: <ending>" when it works, or "RUN FAILED: <why>" quickly when it can't.
## Run:  godot --headless --path . --script res://tests/run_bot.gd
##       add  -- choice=1        to take the second choice in conversations
##       add  -- choices=1,0     to take these choices in order (then the first choice)

const MAX_FRAMES := 15000
const STEPS_PER_FRAME := 4
const NO_PROGRESS_TICKS := 1800     # 30 seconds of game time without getting closer to the goal

var main: Node
var world: Node2D
var f := 0
var phase := "title"
var end_frame := 0
var choice := 0
var plan: Array = []
var ticks := 0
var best := INF
var best_tick := 0
var stuck := 0
var last_x := 0.0
var holding := false
var wait_ticks := 0

func _initialize() -> void:
	for a in OS.get_cmdline_user_args():
		if a.begins_with("choice="):
			choice = int(a.substr(7))
		elif a.begins_with("choices="):
			for c in a.substr(8).split(","):
				plan.append(int(c))
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
				ticks += 1
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
	var at: String = str(world.tile_of(world.player.p)) if world != null else "-"
	print("RUN FAILED: %s (player at tile %s, back to a checkpoint %d times)" % [why, at, world.falls if world != null else 0])
	phase = "failed"
	quit(1)

func _p(key: String, fallback: float) -> float:
	return world._p(key, fallback)

# ---------- deciding what to do ----------
func _steer() -> void:
	if world.is_talking():
		var n: int = world.talking.opts.size() if world.talking.phase == "text" else 0
		var want := choice
		if n > 0 and plan.size() > 0:
			want = plan.pop_front()
		world.choose(clampi(want, 0, max(n - 1, 0)))
		return
	if world.goals.is_empty():
		_fail("the level has no goal")
		return
	var pl: Dictionary = world.player
	var p: Vector2 = pl.p
	var goal: Vector2 = world.goals[0].p
	# go and talk to anyone who has something new to say before heading for the goal
	var npc_target := false
	var nearest := INF
	for s in world.signs:
		var sid0 := _scene_for(s)
		if sid0 != "" and world.last_scene.get(s.id, "") != sid0 and absf(s.p.x - p.x) < nearest:
			nearest = absf(s.p.x - p.x)
			goal = s.p
			npc_target = true
	# getting closer to the target? if not for too long, stop early with a clear message
	var dist := absf(goal.x - p.x)
	if dist < best - 4:
		best = dist
		best_tick = ticks
	elif ticks - best_tick > NO_PROGRESS_TICKS:
		_fail("stuck for 30 seconds without getting closer to the goal")
		return
	# talk to anyone alongside who has something new to say (this tests the conversations and
	# their choices; whether a person can reach them is a level-design question, checked by playing)
	for s in world.signs:
		var sid := _scene_for(s)
		if sid != "" and world.last_scene.get(s.id, "") != sid and absf(s.p.x - p.x) < 46 and absf(s.p.y - p.y) < world.ts * 4:
			world.talk(s)
			return
	var dir := 1.0 if goal.x > p.x else -1.0
	world.ctrl.move = Vector2(dir, 0)
	var jump := false
	if wait_ticks > 0:
		wait_ticks -= 1
		world.ctrl.move = Vector2.ZERO
	elif pl.on_floor:
		if _danger_ahead(p, pl, dir):
			var j := _simulate(true, dir)
			var w := _simulate(false, dir)
			if j.safe and (not w.safe or j.x * dir >= w.x * dir):
				jump = true
			elif w.safe:
				jump = false
			else:
				# neither is safe from here: back up for a run-up, then try again
				world.ctrl.move = Vector2(-dir, 0)
				wait_ticks = 12
		if absf(p.x - last_x) < 0.3:
			stuck += 1
		else:
			stuck = 0
		if stuck > 30:
			jump = true
			stuck = 0
	if jump:
		world.ctrl.jump = true
		holding = true
	last_x = p.x
	if pl.v.y >= 0 and not jump:
		holding = false
	world.ctrl.jump_held = holding

func _scene_for(s: Dictionary) -> String:
	var tk: Variant = s.d.get("talk", "")
	if tk is String:
		return tk
	if tk is Array:
		for entry in tk:
			if entry is Dictionary and world.story.cond(entry.get("if", "")):
				return str(entry.get("scene", ""))
	return ""

## Something in front worth deciding about: a wall, an edge, spikes, or a creature.
func _danger_ahead(p: Vector2, pl: Dictionary, dir: float) -> bool:
	var ts: float = world.ts
	var feet_row := floori((p.y + pl.half.y - 2) / ts)
	var front := floori((p.x + dir * (pl.half.x + 6)) / ts)
	if world.solid(front, feet_row) or world.solid(front, feet_row - 1):
		return true
	if not world.solid(front, feet_row + 1) and not world.platform(front, feet_row + 1):
		return true
	for k in range(1, 3):
		if world.cell(floori((p.x + dir * (pl.half.x + k * ts * 0.6)) / ts), feet_row) == "^":
			return true
	for e in world.enemies:
		if not e.dead and (e.p.x - p.x) * dir > 0 and absf(e.p.x - p.x) < 90 and absf(e.p.y - p.y) < 30:
			return true
	return false

## Plays the next couple of seconds in its head, using the game's own movement and collision:
## jumping now (or not), running toward the goal. Safe means it lands on solid ground with no spikes.
func _simulate(jump: bool, dir: float) -> Dictionary:
	var pl: Dictionary = world.player
	var o := {"p": pl.p, "v": pl.v, "half": pl.half, "on_floor": pl.on_floor}
	var dt := 1.0 / 60.0
	if jump:
		o.v.y = -_p("jump_speed", 600)
		o.on_floor = false
	var left_ground := jump
	for i in 180:
		o.v.x = move_toward(o.v.x, dir * _p("speed", 220), (2400.0 if o.on_floor else 1400.0) * dt)
		o.v.y = minf(o.v.y + _p("gravity", 1500) * dt, _p("max_fall", 900))
		world._move_x(o, o.v.x * dt)
		world._move_y(o, o.v.y * dt)
		var feet_row := floori((o.p.y + 10) / world.ts)
		for tx in range(floori((o.p.x - 6) / world.ts), floori((o.p.x + 6) / world.ts) + 1):
			if world.cell(tx, feet_row) == "^":
				return {"safe": false, "x": o.p.x}
		if o.p.y > world.H * world.ts:
			return {"safe": false, "x": o.p.x}
		if not o.on_floor:
			left_ground = true
		elif left_ground and i > 2:
			return {"safe": true, "x": o.p.x}
		elif not jump and i > 20:
			return {"safe": true, "x": o.p.x}     # just walked along the ground
	return {"safe": false, "x": o.p.x}
