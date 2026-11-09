## The platformer itself: a side-on level built from level.txt. Run, jump, hop on creatures,
## collect things and reach the goal. How it feels (speed, jump height, gravity) comes from
## game.json; creatures and collectibles from entities.json; signs' words from story.json.
## Keys: A/D or arrows to run, Space, W or Up to jump, E to read a sign.
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

var player := {}
var enemies: Array = []
var collectibles: Array = []
var items: Array = []
var checkpoints: Array = []
var goals: Array = []
var signs: Array = []
var respawn := Vector2.ZERO
var item_names := {}
var collect_name := "collectibles"
var got := 0
var last_scene := {}

var actors: Node2D
var cam: Camera2D
var hud: Control
var hud_label: Label
var hud_prompt: Label
var box: PanelContainer
var talking := {}
var ctrl := {"move": Vector2.ZERO, "jump": false, "jump_held": false, "interact": false}
var bot := false
var t := 0.0
var done := false
var falls := 0
var stomped := 0
var enemy_name := "creatures"
var toast := ""
var toast_t := 0.0

func setup(data: RefCounted) -> void:
	D = data

func _ready() -> void:
	story = Story.new()
	story.setup(D.story)
	ts = Data.num(D.game, "tile_size", 32)
	grid = D.level
	H = grid.size()
	for row in grid:
		W = max(W, row.length())
	actors = Node2D.new()
	add_child(actors)
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

func _p(key: String, fallback: float) -> float:
	return Data.num(D.game.get("player", {}), key, fallback)

# ---------- building the level from level.txt ----------
func _build_level() -> void:
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
				var pd: Dictionary = D.game.get("player", {})
				player = {"p": p, "v": Vector2.ZERO, "half": Vector2(10, 14), "on_floor": false, "coyote": 0.0, "buffer": 0.0,
					"hp": _p("health", 3), "inv": 0.0, "flash": 0.0, "face": Vector2.RIGHT,
					"node": _actor(str(pd.get("sprite", "hero")), str(pd.get("color", "#f2ead9")), "circle", 28, "")}
				respawn = p
				continue
			if c in ["#", "=", "^", ".", " "]:
				continue
			var e: Dictionary = D.entity_for_char(c)
			if e.is_empty():
				continue
			var col := str(e.get("color", "#cccccc"))
			var nm := str(e.get("name", e.id))
			match str(e.get("kind", "")):
				"npc":
					signs.append({"id": e.id, "d": e, "p": p, "name": nm, "node": _actor(str(e.get("sprite", e.id)), col, str(e.get("shape", "sign")), 26, "")})
				"enemy":
					enemy_name = nm
					enemies.append({"id": e.id, "d": e, "p": p, "v": Vector2.ZERO, "half": Vector2(12, 10), "dir": -1.0, "dead": false,
						"on_floor": false, "flash": 0.0, "name": nm, "node": _actor(str(e.get("sprite", e.id)), col, str(e.get("shape", "blob")), 24, "")})
				"collectible":
					collect_name = nm
					collectibles.append({"p": p, "taken": false, "node": _actor(str(e.get("sprite", e.id)), col, "diamond", 16, "")})
				"item":
					items.append({"id": e.id, "d": e, "p": p, "taken": false, "name": nm, "node": _actor(str(e.get("sprite", e.id)), col, "star", 22, "")})
				"checkpoint":
					checkpoints.append({"p": p, "node": _actor(str(e.get("sprite", e.id)), col, "flag", 26, "")})
				"goal":
					goals.append({"p": p, "node": _actor(str(e.get("sprite", e.id)), col, "square", 30, "")})
	if player.is_empty():
		push_error("level.txt needs a P where the player starts.")
		player = {"p": Vector2(ts * 1.5, ts * 1.5), "v": Vector2.ZERO, "half": Vector2(10, 14), "on_floor": false, "coyote": 0.0, "buffer": 0.0,
			"hp": 3.0, "inv": 0.0, "flash": 0.0, "face": Vector2.RIGHT, "node": _actor("hero", "#ffffff", "circle", 28, "")}
	for list in [collectibles, items, checkpoints, goals, signs]:
		for o in list:
			o.node.position = o.p

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
	hud_label = Label.new()
	hud_label.position = Vector2(24, 52)
	hud_label.add_theme_font_size_override("font_size", 18)
	hud.add_child(hud_label)
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
	if y < 0 or y >= H:
		return "."
	if x < 0 or x >= grid[y].length():
		return "#"
	return grid[y][x]

func solid(x: int, y: int) -> bool:
	return cell(x, y) == "#"

func platform(x: int, y: int) -> bool:
	return cell(x, y) == "="

func tile_of(p: Vector2) -> Vector2i:
	return Vector2i(floori(p.x / ts), floori(p.y / ts))

func _cols(o: Dictionary) -> Array:
	var p: Vector2 = o.p
	var h: Vector2 = o.half
	return range(floori((p.x - h.x) / ts), floori((p.x + h.x - 0.01) / ts) + 1)

func _move_x(o: Dictionary, dx: float) -> bool:
	var h: Vector2 = o.half
	o.p.x += dx
	var r0 := floori((o.p.y - h.y) / ts)
	var r1 := floori((o.p.y + h.y - 0.01) / ts)
	for tx in _cols(o):
		for ty in range(r0, r1 + 1):
			if solid(tx, ty):
				if dx > 0:
					o.p.x = tx * ts - h.x - 0.01
				elif dx < 0:
					o.p.x = (tx + 1) * ts + h.x + 0.01
				o.v.x = 0.0
				return true
	return false

func _move_y(o: Dictionary, dy: float) -> void:
	var h: Vector2 = o.half
	var old_bottom: float = o.p.y + h.y
	o.p.y += dy
	o.on_floor = false
	if dy > 0:
		var ty := floori((o.p.y + h.y - 0.01) / ts)
		for tx in _cols(o):
			if solid(tx, ty) or (platform(tx, ty) and old_bottom <= ty * ts + 0.5):
				o.p.y = ty * ts - h.y
				o.v.y = 0.0
				o.on_floor = true
				return
	elif dy < 0:
		var ty2 := floori((o.p.y - h.y) / ts)
		for tx in _cols(o):
			if solid(tx, ty2):
				o.p.y = (ty2 + 1) * ts + h.y
				o.v.y = 0.0
				return

func _draw() -> void:
	var ground: Color = D.colour("ground", "#4d4166")
	var top: Color = D.colour("ground_top", "#9a7fb8")
	var plank: Color = D.colour("platform", "#c9a36b")
	var spike: Color = D.colour("spikes", "#d8d8e0")
	for y in H:
		for x in W:
			var o := Vector2(x * ts, y * ts)
			match cell(x, y):
				"#":
					draw_rect(Rect2(o, Vector2(ts, ts)), ground)
					if not solid(x, y - 1):
						draw_rect(Rect2(o, Vector2(ts, 6)), top)
				"=":
					draw_rect(Rect2(o, Vector2(ts, 8)), plank)
					draw_rect(Rect2(o + Vector2(0, 8), Vector2(ts, 2)), plank.darkened(0.4))
				"^":
					for k in 2:
						var bx := o.x + k * ts / 2.0
						draw_colored_polygon(PackedVector2Array([Vector2(bx, o.y + ts), Vector2(bx + ts / 4.0, o.y + ts * 0.35), Vector2(bx + ts / 2.0, o.y + ts)]), spike)

# ---------- each step of the game ----------
func _unhandled_input(e: InputEvent) -> void:
	if bot or not (e is InputEventKey) or e.echo:
		return
	var k: int = e.physical_keycode
	if e.pressed and k in [KEY_SPACE, KEY_W, KEY_UP]:
		ctrl.jump = true
	elif e.pressed and k == KEY_E:
		ctrl.interact = true

func _physics_process(dt: float) -> void:
	if bot:
		return
	var mx := 0.0
	if Input.is_physical_key_pressed(KEY_A) or Input.is_physical_key_pressed(KEY_LEFT): mx -= 1
	if Input.is_physical_key_pressed(KEY_D) or Input.is_physical_key_pressed(KEY_RIGHT): mx += 1
	ctrl.move = Vector2(mx, 0)
	ctrl.jump_held = Input.is_physical_key_pressed(KEY_SPACE) or Input.is_physical_key_pressed(KEY_W) or Input.is_physical_key_pressed(KEY_UP)
	tick(dt)

func tick(dt: float) -> void:
	if done:
		return
	if not talking.is_empty():
		ctrl.jump = false
		ctrl.interact = false
		return
	t += dt
	var speed := _p("speed", 220)
	var target: float = ctrl.move.x * speed
	player.v.x = move_toward(player.v.x, target, (2400.0 if player.on_floor else 1400.0) * dt)
	if absf(ctrl.move.x) > 0.1:
		player.face = Vector2(signf(ctrl.move.x), 0)
	player.buffer = _p("jump_buffer", 0.12) if ctrl.jump else player.buffer - dt
	player.coyote = _p("coyote_time", 0.1) if player.on_floor else player.coyote - dt
	if player.buffer > 0.0 and player.coyote > 0.0:
		player.v.y = -_p("jump_speed", 600)
		player.buffer = 0.0
		player.coyote = 0.0
	var g := _p("gravity", 1500)
	if player.v.y < 0 and not ctrl.jump_held:
		g *= 2.5          # let go of jump early for a smaller hop
	player.v.y = minf(player.v.y + g * dt, _p("max_fall", 900))
	_move_x(player, player.v.x * dt)
	_move_y(player, player.v.y * dt)
	if ctrl.interact:
		for s in signs:
			if s.p.distance_to(player.p) < 50:
				talk(s)
				break
	ctrl.jump = false
	ctrl.interact = false
	player.inv -= dt
	player.flash -= dt
	toast_t -= dt
	# spikes, and falling out of the level
	var hit_spike := false
	for tx in range(floori((player.p.x - 6) / ts), floori((player.p.x + 6) / ts) + 1):
		if cell(tx, floori((player.p.y + 10) / ts)) == "^":
			hit_spike = true
	if hit_spike:
		hurt(1, true)
	elif player.p.y > H * ts + 64:
		hurt(1, true)
	_enemies(dt)
	for c in collectibles:
		if not c.taken and c.p.distance_to(player.p) < 24:
			c.taken = true
			got += 1
			c.node.queue_free()
	for it in items:
		if not it.taken and it.p.distance_to(player.p) < 26:
			it.taken = true
			story.items[it.id] = it.name
			story.apply(it.d, item_names)
			story.note("Found the %s" % it.name)
			it.node.queue_free()
			_toast("Found: %s" % it.name)
	for cp in checkpoints:
		if cp.p.distance_to(player.p) < 30 and respawn != cp.p:
			respawn = cp.p
			_toast("Checkpoint")
	for gl in goals:
		if gl.p.distance_to(player.p) < 30:
			finish("")
			return
	_sync()

func _enemies(dt: float) -> void:
	for e in enemies:
		if e.dead:
			continue
		var speed := Data.num(e.d, "speed", 60)
		e.v.x = e.dir * speed
		e.v.y = minf(e.v.y + _p("gravity", 1500) * dt, _p("max_fall", 900))
		if _move_x(e, e.v.x * dt):
			e.dir = -e.dir
		_move_y(e, e.v.y * dt)
		if e.on_floor:
			var fx := floori((e.p.x + e.dir * (e.half.x + 2)) / ts)
			var fy := floori((e.p.y + e.half.y + 2) / ts)
			if not solid(fx, fy) and not platform(fx, fy):
				e.dir = -e.dir
		e.flash -= dt
		# touching the player: landing on top stops it, anything else hurts
		var dx: float = absf(e.p.x - player.p.x)
		var dy: float = absf(e.p.y - player.p.y)
		if dx < e.half.x + player.half.x and dy < e.half.y + player.half.y:
			var feet: float = player.p.y + player.half.y
			if player.v.y > 0 and feet - (e.p.y - e.half.y) < 16:
				e.dead = true
				e.node.queue_free()
				stomped += 1
				player.v.y = -_p("jump_speed", 600) * 0.55
			elif player.inv <= 0.0:
				hurt(Data.num(e.d, "damage", 1), false)

func hurt(dmg: float, send_back: bool) -> void:
	if player.inv > 0.0 and not send_back:
		return
	player.hp -= dmg
	player.inv = 1.0
	player.flash = 0.3
	player.v = Vector2(-player.face.x * 200, -250)
	if player.hp <= 0 or send_back:
		if player.hp <= 0:
			player.hp = _p("health", 3)
		falls += 1
		player.p = respawn
		player.v = Vector2.ZERO
		player.inv = 1.2
		_toast("Back to the last checkpoint")

func _sync() -> void:
	var pn: Node2D = player.node
	pn.position = player.p
	pn.flash = player.flash
	var st := "idle"
	if not player.on_floor:
		st = "jump" if player.v.y < 0 else "fall"
	elif absf(player.v.x) > 20:
		st = "run"
	pn.show_state(st, player.face)
	for e in enemies:
		if not e.dead:
			e.node.position = e.p
			e.node.flash = e.flash
			e.node.show_state("walk", Vector2(e.dir, 0))
	cam.position = player.p
	hud.queue_redraw()
	hud_label.text = "%s: %d / %d" % [collect_name.capitalize(), got, collectibles.size()] if collectibles.size() > 0 else ""
	hud_prompt.text = toast if toast_t > 0.0 else _prompt()

func _prompt() -> String:
	for s in signs:
		if s.p.distance_to(player.p) < 50:
			return "E: read the %s" % s.name.to_lower()
	return ""

func _toast(s: String) -> void:
	toast = s
	toast_t = 1.8

# ---------- signs (they use story.json, like conversations) ----------
func talk(s: Dictionary) -> void:
	var tk: Variant = s.d.get("talk", "")
	var sid := ""
	if tk is String:
		sid = tk
	elif tk is Array:
		for entry in tk:
			if entry is Dictionary and story.cond(entry.get("if", "")):
				sid = str(entry.get("scene", ""))
				break
	var sc: Variant = story.scenes.get(sid, null)
	if not (sc is Dictionary):
		return
	story.enter(sc)
	last_scene[s.id] = sid
	var opts: Array = story.options_of(sc)
	talking = {"opts": opts, "phase": "text", "name": s.name}
	var labels: Array = opts.map(func(o): return str(o.get("t", "...")))
	box.show_page(str(sc.get("speaker", s.name)), story.text_of(sc), labels if labels.size() > 0 else ["Continue"])

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
		if str(o.get("o", "")) != "":
			talking.phase = "outcome"
			box.show_page(talking.name, str(o["o"]), ["Continue"])
			return
	talking = {}
	box.visible = false

# ---------- the ending ----------
func finish(ending_id: String) -> void:
	if done:
		return
	done = true
	var chosen := {}
	for en in D.game.get("endings", []):
		if en is Dictionary and ((ending_id != "" and str(en.get("id", "")) == ending_id) or (ending_id == "" and story.cond(en.get("if", "")))):
			chosen = en
			break
	if chosen.is_empty():
		chosen = {"id": "end", "title": "The End", "text": ""}
	var recap: Array = story.log.duplicate()
	if collectibles.size() > 0:
		recap.append("Collected %d of %d %s" % [got, collectibles.size(), collect_name])
	if stomped > 0:
		recap.append("Hopped on %d %s" % [stomped, enemy_name])
	if falls > 0:
		recap.append("Went back to a checkpoint %d time%s" % [falls, "" if falls == 1 else "s"])
	recap.append("Time: %d:%02d" % [int(t) / 60, int(t) % 60])
	finished.emit(chosen, recap)

func _draw_hud() -> void:
	for i in int(_p("health", 3)):
		var c := Vector2(34 + i * 30, 30)
		hud.draw_circle(c, 11, Color(0.1, 0.1, 0.12, 0.7))
		if i < int(ceil(player.hp)):
			hud.draw_circle(c, 9, D.colour("health", "#e0574f"))
