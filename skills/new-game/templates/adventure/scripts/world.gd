## The adventure itself: a top-down area built from level.txt, with people to talk to, creatures
## to face, things to pick up, doors and a goal. Numbers come from game.json, characters and
## creatures from entities.json, and conversations from story.json.
## Keys: WASD or arrows to move, Space to swing, E to talk or open.
extends Node2D

signal finished(ending: Dictionary, recap: Array)

const Actor := preload("res://scripts/actor.gd")
const Story := preload("res://scripts/story.gd")
const DialogueBox := preload("res://scripts/dialogue_box.gd")
const Data := preload("res://scripts/data.gd")

var D: RefCounted
var story: RefCounted
var ts := 32.0
var grid: PackedStringArray
var W := 0
var H := 0
var rng := RandomNumberGenerator.new()

var player := {}
var npcs: Array = []
var enemies: Array = []
var items: Array = []
var doors: Array = []
var checkpoints: Array = []
var goals: Array = []
var shots: Array = []
var respawn := Vector2.ZERO
var item_names := {}
var last_scene := {}      # character id -> the last conversation shown (the test bot reads this)

var actors: Node2D
var fx: Node2D
var cam: Camera2D
var hud: Control
var hud_items: Label
var hud_prompt: Label
var box: PanelContainer
var talking := {}
var ctrl := {"move": Vector2.ZERO, "action": false, "interact": false}
var bot := false          # true when the test bot is playing
var t := 0.0
var done := false
var falls := 0
var defeated := {}
var swing := 0.0
var toast := ""
var toast_t := 0.0

func setup(data: RefCounted) -> void:
	D = data

func _ready() -> void:
	rng.seed = 7
	story = Story.new()
	story.setup(D.story)
	ts = Data.num(D.game, "tile_size", 32)
	grid = D.level
	H = grid.size()
	for row in grid:
		W = max(W, row.length())
	actors = Node2D.new()
	actors.y_sort_enabled = true
	add_child(actors)
	fx = Node2D.new()
	fx.z_index = 50
	fx.draw.connect(_draw_fx)
	add_child(fx)
	cam = Camera2D.new()
	cam.position_smoothing_enabled = true
	cam.limit_left = 0
	cam.limit_top = 0
	cam.limit_right = int(W * ts)
	cam.limit_bottom = int(H * ts)
	# zoom in so the level always fills the screen, even a small one
	var vs := get_viewport_rect().size
	var z := maxf(1.0, maxf(vs.x / (W * ts), vs.y / (H * ts)))
	cam.zoom = Vector2(z, z)
	add_child(cam)
	_build_level()
	_build_ui()
	cam.position = player.p
	cam.reset_smoothing()
	queue_redraw()

# ---------- building the level from level.txt ----------
func _build_level() -> void:
	var pd: Dictionary = D.game.get("player", {})
	for e in D.entities:
		var ed: Variant = D.entities[e]
		if ed is Dictionary and ed.get("kind", "") == "item":
			item_names[e] = str(ed.get("name", e))
	for y in H:
		var row := grid[y]
		for x in row.length():
			var c := row[x]
			var p := Vector2((x + 0.5) * ts, (y + 0.5) * ts)
			if c == "P":
				player = {"p": p, "face": Vector2.DOWN, "hp": Data.num(pd, "health", 5), "inv": 0.0, "atk": 0.0, "flash": 0.0,
					"node": _actor(str(pd.get("sprite", "hero")), str(pd.get("color", "#f2ead9")), "circle", 26, "")}
				respawn = p
				continue
			if c in ["#", "~", ".", " "]:
				continue
			var e: Dictionary = D.entity_for_char(c)
			if e.is_empty():
				continue
			var col := str(e.get("color", "#cccccc"))
			var nm := str(e.get("name", e.id))
			match str(e.get("kind", "")):
				"npc":
					npcs.append({"id": e.id, "d": e, "p": p, "name": nm, "node": _actor(str(e.get("sprite", e.id)), col, "square", 26, nm)})
				"enemy":
					enemies.append({"id": e.id, "d": e, "p": p, "home": p, "hp": Data.num(e, "health", 2), "dead": false, "t": 0.0,
						"dir": Vector2.ZERO, "kb": Vector2.ZERO, "cool": 1.0, "flash": 0.0, "name": nm,
						"node": _actor(str(e.get("sprite", e.id)), col, str(e.get("shape", "blob")), 24, "")})
				"item":
					items.append({"id": e.id, "d": e, "p": p, "taken": false, "name": nm, "node": _actor(str(e.get("sprite", e.id)), col, "diamond", 18, "")})
				"door":
					doors.append({"id": e.id, "d": e, "x": x, "y": y, "p": p, "open": false, "name": nm, "node": _actor(str(e.get("sprite", e.id)), col, "door", ts, "")})
				"checkpoint":
					checkpoints.append({"p": p, "node": _actor(str(e.get("sprite", e.id)), col, "flag", 24, "")})
				"goal":
					goals.append({"p": p, "node": _actor(str(e.get("sprite", e.id)), col, "star", 30, "")})
	if player.is_empty():
		push_error("level.txt needs a P where the player starts.")
		player = {"p": Vector2(ts * 1.5, ts * 1.5), "face": Vector2.DOWN, "hp": 5.0, "inv": 0.0, "atk": 0.0, "flash": 0.0, "node": _actor("hero", "#ffffff", "circle", 26, "")}

func _actor(id: String, col: String, shape: String, size: float, label: String) -> Node2D:
	var a: Node2D = Actor.new().setup(id, Color.from_string(col, Color.WHITE), shape, size, label)
	actors.add_child(a)
	return a

func _build_ui() -> void:
	var layer := CanvasLayer.new()
	add_child(layer)
	hud = Control.new()
	hud.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	hud.mouse_filter = Control.MOUSE_FILTER_IGNORE
	hud.draw.connect(_draw_hud)
	layer.add_child(hud)
	hud_items = Label.new()
	hud_items.position = Vector2(24, 52)
	hud_items.add_theme_font_size_override("font_size", 18)
	hud.add_child(hud_items)
	hud_prompt = Label.new()
	hud_prompt.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	hud_prompt.offset_top = -70
	hud_prompt.offset_left = -300
	hud_prompt.offset_right = 300
	hud_prompt.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hud_prompt.add_theme_font_size_override("font_size", 20)
	hud.add_child(hud_prompt)
	box = DialogueBox.new()
	box.build(D)
	box.picked.connect(_on_pick)
	layer.add_child(box)

# ---------- the map ----------
func cell(x: int, y: int) -> String:
	if y < 0 or y >= H or x < 0 or x >= grid[y].length():
		return "#"
	return grid[y][x]

func solid(x: int, y: int) -> bool:
	var c := cell(x, y)
	if c == "#" or c == "~":
		return true
	for d in doors:
		if not d.open and d.x == x and d.y == y:
			return true
	return false

func tile_of(p: Vector2) -> Vector2i:
	return Vector2i(floori(p.x / ts), floori(p.y / ts))

func _blocked(p: Vector2, half: float) -> bool:
	for o in [Vector2(-half, -half), Vector2(half, -half), Vector2(-half, half), Vector2(half, half)]:
		var tp := tile_of(p + o)
		if solid(tp.x, tp.y):
			return true
	return false

func _move(obj: Dictionary, delta: Vector2, half := 10.0) -> void:
	var p: Vector2 = obj.p
	if not _blocked(p + Vector2(delta.x, 0), half):
		p.x += delta.x
	if not _blocked(p + Vector2(0, delta.y), half):
		p.y += delta.y
	obj.p = p

func _draw() -> void:
	var floor_c: Color = D.colour("floor", "#3a4458")
	var wall_c: Color = D.colour("wall", "#5b6680")
	var water_c: Color = D.colour("water", "#2f6d8f")
	for y in H:
		for x in W:
			var r := Rect2(x * ts, y * ts, ts, ts)
			match cell(x, y):
				"#":
					draw_rect(r, wall_c)
					draw_rect(Rect2(r.position + Vector2(0, ts - 6), Vector2(ts, 6)), wall_c.darkened(0.35))
				"~":
					draw_rect(r, water_c)
					draw_line(r.position + Vector2(6, ts * 0.4), r.position + Vector2(ts - 10, ts * 0.4), water_c.lightened(0.3), 2.0)
				_:
					draw_rect(r, floor_c if (x + y) % 2 == 0 else floor_c.darkened(0.06))

# ---------- each step of the game ----------
func _unhandled_input(e: InputEvent) -> void:
	if bot or not (e is InputEventKey) or not e.pressed or e.echo:
		return
	if e.physical_keycode == KEY_SPACE:
		ctrl.action = true
	elif e.physical_keycode == KEY_E:
		ctrl.interact = true

func _physics_process(dt: float) -> void:
	if bot:
		return
	var mv := Vector2.ZERO
	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT): mv.x -= 1
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT): mv.x += 1
	if Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP): mv.y -= 1
	if Input.is_physical_key_pressed(KEY_S) or Input.is_physical_key_pressed(KEY_DOWN): mv.y += 1
	ctrl.move = mv
	tick(dt)

func tick(dt: float) -> void:
	if done:
		return
	if not talking.is_empty():
		ctrl.action = false
		ctrl.interact = false
		return
	t += dt
	var pd: Dictionary = D.game.get("player", {})
	var mv: Vector2 = ctrl.move
	if mv.length() > 1.0:
		mv = mv.normalized()
	_move(player, mv * Data.num(pd, "speed", 150) * dt)
	if mv.length() > 0.1:
		player.face = mv.normalized()
	player.inv -= dt
	player.atk -= dt
	player.flash -= dt
	swing -= dt
	toast_t -= dt
	if ctrl.action and player.atk <= 0.0 and can_attack():
		_attack(Data.num(pd, "attack_damage", 1))
	if ctrl.interact:
		_interact()
	ctrl.action = false
	ctrl.interact = false
	for d in doors:
		if not d.open and str(d.d.get("opens_if", "")) != "" and story.cond(d.d.get("opens_if", "")):
			_open(d)
	_enemies(dt)
	_shots(dt)
	for it in items:
		if not it.taken and it.p.distance_to(player.p) < 24:
			it.taken = true
			story.items[it.id] = it.name
			story.apply(it.d, item_names)
			story.note("Found the %s" % it.name)
			it.node.queue_free()
			_toast("Found: %s" % it.name)
	for cp in checkpoints:
		if cp.p.distance_to(player.p) < 26 and respawn != cp.p:
			respawn = cp.p
			_toast("Checkpoint")
	for g in goals:
		if g.p.distance_to(player.p) < 26:
			finish("")
			return
	_sync()

func _sync() -> void:
	var pn: Node2D = player.node
	pn.position = player.p
	pn.flash = player.flash
	pn.show_state("attack" if player.atk > 0.0 else ("walk" if ctrl.move.length() > 0.1 else "idle"), player.face)
	for e in enemies:
		if not e.dead:
			e.node.position = e.p
			e.node.flash = e.flash
			e.node.show_state("walk" if e.dir.length() > 0.1 else "idle", e.dir)
	for n in npcs:
		n.node.position = n.p
		n.node.show_state("idle", (player.p - n.p))
	for list in [items, doors, checkpoints, goals]:
		for o in list:
			if is_instance_valid(o.node):
				o.node.position = o.p
	cam.position = player.p
	fx.queue_redraw()
	hud.queue_redraw()
	var names: Array = story.items.values()
	hud_items.text = ("Carrying: " + ", ".join(names)) if names.size() > 0 else ""
	hud_prompt.text = toast if toast_t > 0.0 else _prompt()

func _prompt() -> String:
	var n := _near_npc()
	if not n.is_empty():
		return "E: talk to %s" % n.name
	var d := _near_door()
	if not d.is_empty():
		return "E: open the %s" % d.name if can_open(d) else "The %s is locked" % d.name
	return ""

func _toast(s: String) -> void:
	toast = s
	toast_t = 1.8

# ---------- fighting ----------
func _attack(dmg: float) -> void:
	player.atk = 0.3
	swing = 0.15
	for e in enemies:
		if e.dead:
			continue
		var d: Vector2 = e.p - player.p
		if d.length() < 50 and (d.length() < 22 or d.normalized().dot(player.face) > 0.2):
			e.hp -= dmg
			e.flash = 0.2
			e.kb = d.normalized() * 260
			if e.hp <= 0:
				e.dead = true
				e.node.queue_free()
				defeated[e.name] = int(defeated.get(e.name, 0)) + 1

func _enemies(dt: float) -> void:
	for e in enemies:
		if e.dead:
			continue
		var d: Dictionary = e.d
		var to: Vector2 = player.p - e.p
		var dist := to.length()
		var speed := Data.num(d, "speed", 60)
		var sight := Data.num(d, "sight", 180)
		var vel := Vector2.ZERO
		match str(d.get("behaviour", "wander")):
			"chase":
				if dist < sight:
					vel = to.normalized() * speed
				elif e.p.distance_to(e.home) > 6:
					vel = (e.home - e.p).normalized() * speed * 0.6
			"keep_away":
				var want := ts * 4.0
				if dist < sight:
					if dist < want - 20:
						vel = -to.normalized() * speed
					elif dist > want + 20:
						vel = to.normalized() * speed * 0.6
					e.cool -= dt
					if e.cool <= 0.0:
						e.cool = Data.num(d, "shoot_every", 2.0)
						shots.append({"p": e.p, "v": to.normalized() * 160.0, "life": 3.0, "dmg": Data.num(d, "damage", 1), "col": e.node.color})
			_:
				e.t -= dt
				if e.t <= 0.0:
					e.t = rng.randf_range(1.0, 2.5)
					e.dir = Vector2.from_angle(rng.randf() * TAU) if rng.randf() < 0.7 else Vector2.ZERO
				if e.p.distance_to(e.home) > ts * 2.5:
					e.dir = (e.home - e.p).normalized()
				vel = e.dir * speed
		if str(d.get("behaviour", "wander")) != "wander":
			e.dir = vel.normalized() if vel.length() > 1 else Vector2.ZERO
		e.flash -= dt
		_move(e, (vel + e.kb) * dt, 10)
		e.kb = e.kb.move_toward(Vector2.ZERO, 900 * dt)
		if dist < 24 and player.inv <= 0.0:
			if sends_back():
				caught()
			else:
				hurt(Data.num(d, "damage", 1), e.p)

func _shots(dt: float) -> void:
	for s in shots:
		s.p += s.v * dt
		s.life -= dt
		var tp := tile_of(s.p)
		if cell(tp.x, tp.y) == "#":
			s.life = 0.0
		elif s.p.distance_to(player.p) < 16 and player.inv <= 0.0:
			hurt(s.dmg, s.p)
			s.life = 0.0
	shots = shots.filter(func(s): return s.life > 0.0)

func hurt(dmg: float, from: Vector2) -> void:
	player.hp -= dmg
	player.inv = 0.9
	player.flash = 0.3
	_move(player, (player.p - from).normalized() * 18)
	if player.hp <= 0:
		falls += 1
		player.hp = Data.num(D.game.get("player", {}), "health", 5)
		player.p = respawn
		player.inv = 1.5
		_toast("Back to the last checkpoint")

## game.json "player": {"can_attack": false} turns off swinging, for gentle games.
func can_attack() -> bool:
	return bool((D.game.get("player", {}) as Dictionary).get("can_attack", true))

## game.json "enemy_touch": "send_back" means being caught sends you back to the last checkpoint
## instead of costing health (and the hearts are hidden). The default, "hurt", costs health.
func sends_back() -> bool:
	return str(D.game.get("enemy_touch", "hurt")) == "send_back"

func caught() -> void:
	falls += 1
	player.p = respawn
	player.inv = 1.5
	player.flash = 0.3
	_toast("Caught! Back to the last checkpoint")

# ---------- talking and doors ----------
func _near_npc() -> Dictionary:
	for n in npcs:
		if n.p.distance_to(player.p) < 52:
			return n
	return {}

func _near_door() -> Dictionary:
	for d in doors:
		if not d.open and d.p.distance_to(player.p) < 50:
			return d
	return {}

func _interact() -> void:
	var n := _near_npc()
	if not n.is_empty():
		talk(n)
		return
	var d := _near_door()
	if not d.is_empty():
		if can_open(d):
			_open(d)
		else:
			_toast("The %s is locked." % d.name)

func can_open(d: Dictionary) -> bool:
	var needs := str(d.d.get("needs", ""))
	var opens_if := str(d.d.get("opens_if", ""))
	if needs == "" and opens_if == "":
		return true
	return (needs != "" and story.items.has(needs)) or (opens_if != "" and story.cond(opens_if))

func _open(d: Dictionary) -> void:
	d.open = true
	d.node.open = true
	if d.node.spr != null:
		d.node.spr.visible = false      # a door with art: an open door shows the open shape
	d.node.queue_redraw()
	story.note("Opened the %s" % d.name)

## Which conversation this character starts right now. "talk" in entities.json is either one
## scene name, or a list like [{"if": "has:key", "scene": "ada_key"}, {"scene": "ada_hello"}].
func npc_scene(n: Dictionary) -> String:
	var tk: Variant = n.d.get("talk", "")
	if tk is String:
		return tk
	if tk is Array:
		for entry in tk:
			if entry is Dictionary and story.cond(entry.get("if", "")):
				return str(entry.get("scene", ""))
	return ""

func talk(n: Dictionary) -> void:
	story.note("Talked to %s" % n.name)
	_show_scene(n, npc_scene(n))

func _show_scene(n: Dictionary, sid: String) -> void:
	var sc: Variant = story.scenes.get(sid, null)
	if not (sc is Dictionary):
		_close()
		return
	story.enter(sc)
	last_scene[n.id] = sid
	var opts: Array = story.options_of(sc)
	talking = {"n": n, "sid": sid, "opts": opts, "phase": "text", "next": str(sc.get("next", ""))}
	var labels: Array = opts.map(func(o): return str(o.get("t", "...")))
	if labels.is_empty():
		labels = ["Continue"]
	box.show_page(str(sc.get("speaker", n.name)), story.text_of(sc), labels)

func is_talking() -> bool:
	return not talking.is_empty()

func choose(i: int) -> void:
	_on_pick(i)

func _on_pick(i: int) -> void:
	if talking.is_empty():
		return
	if talking.phase == "text" and talking.opts.size() > 0:
		var o: Dictionary = talking.opts[clampi(i, 0, talking.opts.size() - 1)]
		story.apply(o, item_names)
		story.note("You chose: %s" % str(o.get("t", "")))
		talking.next = str(o.get("next", ""))
		if o.has("end"):
			_close()
			finish(str(o["end"]))
			return
		if str(o.get("o", "")) != "":
			talking.phase = "outcome"
			box.show_page(talking.n.name, str(o["o"]), ["Continue"])
			return
	var nxt: String = talking.next
	if nxt != "":
		_show_scene(talking.n, nxt)
	else:
		_close()

func _close() -> void:
	talking = {}
	box.visible = false

# ---------- the ending ----------
func finish(ending_id: String) -> void:
	if done:
		return
	done = true
	var chosen := {}
	for en in D.game.get("endings", []):
		if not (en is Dictionary):
			continue
		if (ending_id != "" and str(en.get("id", "")) == ending_id) or (ending_id == "" and story.cond(en.get("if", ""))):
			chosen = en
			break
	if chosen.is_empty():
		chosen = {"id": ending_id if ending_id != "" else "end", "title": "The End", "text": ""}
	var recap: Array = story.log.duplicate()
	for nm in defeated:
		recap.append("Defeated %d %s" % [defeated[nm], nm])
	if falls > 0:
		recap.append("%s %d time%s" % ["Got caught" if sends_back() else "Went back to a checkpoint", falls, "" if falls == 1 else "s"])
	recap.append("Time: %d:%02d" % [int(t) / 60, int(t) % 60])
	finished.emit(chosen, recap)

# ---------- drawing the hearts and the swing ----------
func _draw_hud() -> void:
	if sends_back():
		return          # no hearts in a game where nobody gets hurt
	var max_hp := Data.num(D.game.get("player", {}), "health", 5)
	for i in int(max_hp):
		var c := Vector2(34 + i * 30, 30)
		hud.draw_circle(c, 11, Color(0.1, 0.1, 0.12, 0.7))
		if i < int(ceil(player.hp)):
			hud.draw_circle(c, 9, D.colour("health", "#e0574f"))

func _draw_fx() -> void:
	if swing > 0.0:
		var a: float = player.face.angle()
		fx.draw_arc(player.p, 38, a - 1.0, a + 1.0, 12, Color(1, 1, 1, 0.8), 4.0)
	for s in shots:
		fx.draw_circle(s.p, 6, s.col)
