## The story game: one scene at a time, each with a background, up to two characters, words,
## and 2 to 4 choices. Choices set flags and counters that change later scenes and pick the
## ending. Scenes are in story.json, characters and backgrounds in entities.json, endings in game.json.
## Choose with the mouse, with 1-4, or with the arrow keys and Space or Enter.
extends Node2D

signal finished(ending: Dictionary, recap: Array)

const Actor := preload("res://scripts/actor.gd")
const Story := preload("res://scripts/story.gd")
const DialogueBox := preload("res://scripts/dialogue_box.gd")
const SB := preload("res://scripts/sprite_bank.gd")
const Data := preload("res://scripts/data.gd")

var D: RefCounted
var story: RefCounted
var layer: CanvasLayer
var bg: ColorRect
var bg_art: TextureRect
var place_label: Label
var timer_bar: ProgressBar
var portraits := {}         # character id -> its portrait on screen
var player := {}            # the hero's portrait (the art swap test looks here)
var box: PanelContainer
var talking := {}
var last_scene := {}
var bot := false
var done := false
var t := 0.0
var time_left := -1.0
var scenes_seen := 0

func setup(data: RefCounted) -> void:
	D = data

func _ready() -> void:
	story = Story.new()
	story.setup(D.story)
	layer = CanvasLayer.new()
	add_child(layer)
	bg = ColorRect.new()
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg.color = D.colour("background", "#1f1a24")
	layer.add_child(bg)
	bg_art = TextureRect.new()
	bg_art.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bg_art.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	bg_art.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	bg_art.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	layer.add_child(bg_art)
	place_label = Label.new()
	place_label.position = Vector2(28, 20)
	place_label.add_theme_font_size_override("font_size", 22)
	place_label.add_theme_color_override("font_color", D.colour("accent", "#f0a95e"))
	layer.add_child(place_label)
	timer_bar = ProgressBar.new()
	timer_bar.set_anchors_and_offsets_preset(Control.PRESET_TOP_WIDE)
	timer_bar.offset_top = 64
	timer_bar.offset_bottom = 72
	timer_bar.offset_left = 28
	timer_bar.offset_right = -28
	timer_bar.show_percentage = false
	timer_bar.visible = false
	layer.add_child(timer_bar)
	var holder := Node2D.new()
	layer.add_child(holder)
	for id in D.entities:
		var e: Dictionary = D.entity(id)
		if str(e.get("kind", "")) == "character":
			var a: Node2D = Actor.new().setup(str(e.get("sprite", id)), Color.from_string(str(e.get("color", "#cccccc")), Color.WHITE), "square", 170, str(e.get("name", id)))
			a.visible = false
			holder.add_child(a)
			portraits[id] = a
	if portraits.has("hero"):
		player = {"node": portraits["hero"]}
	box = DialogueBox.new()
	box.build(D)
	box.picked.connect(_on_pick)
	layer.add_child(box)
	_show_scene(str(D.game.get("start_scene", "start")))

func _process(dt: float) -> void:
	if not bot:
		tick(dt)

## Only the countdown on timed choices moves with time.
func tick(dt: float) -> void:
	if done:
		return
	t += dt
	if time_left > 0.0:
		time_left -= dt
		timer_bar.value = time_left
		if time_left <= 0.0:
			var sc: Dictionary = story.scenes.get(talking.get("sid", ""), {})
			_on_pick(int(sc.get("timeout_option", talking.opts.size() - 1)))

func _show_scene(sid: String) -> void:
	var sc: Variant = story.scenes.get(sid, null)
	if not (sc is Dictionary):
		push_error("story.json has no scene called '%s'." % sid)
		finish("")
		return
	scenes_seen += 1
	story.enter(sc)
	last_scene["story"] = sid
	# the place: background colour, and its picture if there is art for it
	var place: Dictionary = D.entity(str(sc.get("background", "")))
	bg.color = Color.from_string(str(place.get("color", "")), D.colour("background", "#1f1a24"))
	place_label.text = str(place.get("name", ""))
	bg_art.texture = null
	var f := SB.frames(str(place.get("sprite", "")))
	if f != null:
		bg_art.texture = f.get_frame_texture(SB.pick(f, "idle"), 0)
	# the characters on the left and right
	for id in portraits:
		portraits[id].visible = false
	var vs := get_viewport().get_visible_rect().size
	for side in ["left", "right"]:
		var id := str(sc.get(side, ""))
		if portraits.has(id):
			var a: Node2D = portraits[id]
			a.visible = true
			a.position = Vector2(vs.x * (0.22 if side == "left" else 0.78), vs.y * 0.42)
			a.show_state("talk" if str(sc.get("speaker", "")) == str(a.label) else "idle", Vector2.RIGHT if side == "left" else Vector2.LEFT)
	var opts: Array = story.options_of(sc)
	talking = {"sid": sid, "opts": opts, "phase": "text", "next": str(sc.get("next", "")), "end": sc.get("end", null)}
	var labels: Array = opts.map(func(o): return str(o.get("t", "...")))
	box.show_page(str(sc.get("speaker", "")), story.text_of(sc), labels if labels.size() > 0 else ["Continue"])
	# a countdown, only if timed choices are switched on in game.json and this scene has one
	time_left = -1.0
	timer_bar.visible = false
	if bool(D.game.get("timed_choices", false)) and sc.has("timer") and opts.size() > 0:
		time_left = Data.num(sc, "timer", 10)
		timer_bar.max_value = time_left
		timer_bar.value = time_left
		timer_bar.visible = true

func is_talking() -> bool:
	return not talking.is_empty() and not done

func choose(i: int) -> void:
	_on_pick(i)

func _on_pick(i: int) -> void:
	if talking.is_empty() or done:
		return
	time_left = -1.0
	timer_bar.visible = false
	if talking.phase == "text" and talking.opts.size() > 0:
		var o: Dictionary = talking.opts[clampi(i, 0, talking.opts.size() - 1)]
		story.apply(o)
		story.note("You chose: %s" % str(o.get("t", "")))
		talking.next = str(o.get("next", talking.next))
		if o.has("end"):
			talking.end = o["end"]
		if str(o.get("o", "")) != "":
			talking.phase = "outcome"
			box.show_page("", str(o["o"]), ["Continue"])
			return
	if talking.end != null and not (talking.end is bool and talking.end == false):
		finish(talking.end if talking.end is String else "")
	elif talking.next != "":
		_show_scene(talking.next)
	else:
		finish("")

func finish(ending_id: String) -> void:
	if done:
		return
	done = true
	box.visible = false
	var chosen := {}
	for en in D.game.get("endings", []):
		if en is Dictionary and ((ending_id != "" and str(en.get("id", "")) == ending_id) or (ending_id == "" and story.cond(en.get("if", "")))):
			chosen = en
			break
	if chosen.is_empty():
		chosen = {"id": "end", "title": "The End", "text": ""}
	var recap: Array = story.log.duplicate()
	recap.append("Scenes: %d" % scenes_seen)
	finished.emit(chosen, recap)
