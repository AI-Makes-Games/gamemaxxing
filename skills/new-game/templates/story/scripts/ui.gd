## The title screen and the ending screen. Their words and colours come from game.json.
extends RefCounted

const SB := preload("res://scripts/sprite_bank.gd")

static func _label(text: String, size: int, col: Color) -> Label:
	var l := Label.new()
	l.text = text
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	l.custom_minimum_size = Vector2(900, 0)
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	return l

static func _screen(D: RefCounted) -> Array:
	var root := ColorRect.new()
	root.color = D.colour("background", "#1d2330")
	root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(center)
	var box := VBoxContainer.new()
	box.alignment = BoxContainer.ALIGNMENT_CENTER
	box.add_theme_constant_override("separation", 18)
	center.add_child(box)
	return [root, box]

static func _button(text: String, D: RefCounted, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.custom_minimum_size = Vector2(260, 56)
	b.add_theme_font_size_override("font_size", 24)
	b.pressed.connect(cb)
	b.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	b.call_deferred("grab_focus")
	return b

static func title_screen(D: RefCounted, on_start: Callable) -> Control:
	var parts := _screen(D)
	var box: VBoxContainer = parts[1]
	var text_col: Color = D.colour("text", "#f2ead9")
	# the student's logo (art/logo/logo_idle.png, made by the art skill) sits above the title
	var logo := SB.frames("logo")
	if logo != null:
		var tr := TextureRect.new()
		tr.texture = logo.get_frame_texture(SB.pick(logo, "idle"), 0)
		tr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		tr.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		tr.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tr.custom_minimum_size = Vector2(640, 200)
		box.add_child(tr)
	box.add_child(_label(str(D.game.get("title", "My Game")), 64, D.colour("accent", "#f2b84b")))
	box.add_child(_label(str(D.game.get("tagline", "")), 24, text_col))
	box.add_child(Control.new())
	box.add_child(_button("Start", D, on_start))
	box.add_child(_label("Press Space or Enter to start", 16, text_col.darkened(0.3)))
	if str(D.game.get("how_to_play", "")) != "":
		box.add_child(_label(str(D.game["how_to_play"]), 18, text_col))
	return parts[0]

static func ending_screen(D: RefCounted, ending: Dictionary, recap: Array, on_done: Callable) -> Control:
	var parts := _screen(D)
	var box: VBoxContainer = parts[1]
	var text_col: Color = D.colour("text", "#f2ead9")
	box.add_child(_label("The End", 20, text_col.darkened(0.3)))
	box.add_child(_label(str(ending.get("title", "The End")), 52, D.colour("accent", "#f2b84b")))
	box.add_child(_label(str(ending.get("text", "")), 22, text_col))
	if recap.size() > 0:
		box.add_child(_label("What you did", 18, D.colour("accent", "#f2b84b")))
		box.add_child(_label("\n".join(recap), 17, text_col))
	box.add_child(_button("Back to the title", D, on_done))
	return parts[0]
