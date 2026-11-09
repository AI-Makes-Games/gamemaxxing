## The box at the bottom of the screen: who's talking, what they say, and the choices.
## Choose with the mouse, with 1-4, or with the arrow keys and Space or Enter.
extends PanelContainer

signal picked(index: int)

var name_label: Label
var text_label: RichTextLabel
var options_box: VBoxContainer
var count := 0

func build(D: RefCounted) -> void:
	set_anchors_and_offsets_preset(Control.PRESET_BOTTOM_WIDE)
	offset_left = 40
	offset_right = -40
	offset_top = -250
	offset_bottom = -24
	grow_vertical = Control.GROW_DIRECTION_BEGIN   # long text and many choices make it taller upwards, never off the screen
	var sb := StyleBoxFlat.new()
	sb.bg_color = D.colour("panel", "#141821")
	sb.border_color = D.colour("accent", "#f2b84b")
	sb.set_border_width_all(2)
	sb.set_corner_radius_all(8)
	sb.set_content_margin_all(16)
	add_theme_stylebox_override("panel", sb)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 8)
	add_child(v)
	name_label = Label.new()
	name_label.add_theme_font_size_override("font_size", 20)
	name_label.add_theme_color_override("font_color", D.colour("accent", "#f2b84b"))
	v.add_child(name_label)
	text_label = RichTextLabel.new()
	text_label.bbcode_enabled = true
	text_label.fit_content = true
	text_label.scroll_active = false
	text_label.add_theme_font_size_override("normal_font_size", 19)
	text_label.add_theme_color_override("default_color", D.colour("text", "#f2ead9"))
	v.add_child(text_label)
	options_box = VBoxContainer.new()
	v.add_child(options_box)
	visible = false

func show_page(speaker: String, text: String, options: Array) -> void:
	visible = true
	name_label.text = speaker
	name_label.visible = speaker != ""
	text_label.text = text
	for c in options_box.get_children():
		options_box.remove_child(c)
		c.free()
	count = options.size()
	for i in options.size():
		var b := Button.new()
		b.text = "%d.  %s" % [i + 1, str(options[i])]
		b.alignment = HORIZONTAL_ALIGNMENT_LEFT
		b.add_theme_font_size_override("font_size", 18)
		b.pressed.connect(func(): picked.emit(i))
		options_box.add_child(b)
	if count > 0 and is_inside_tree():
		(options_box.get_child(0) as Button).call_deferred("grab_focus")

func _unhandled_input(e: InputEvent) -> void:
	if not visible or not (e is InputEventKey) or not e.pressed or e.echo:
		return
	var k: int = e.physical_keycode
	if k >= KEY_1 and k <= KEY_9 and k - KEY_1 < count:
		picked.emit(k - KEY_1)
		get_viewport().set_input_as_handled()
	elif k == KEY_E and count > 0:
		var idx := 0
		for i in count:
			if (options_box.get_child(i) as Button).has_focus():
				idx = i
		picked.emit(idx)
		get_viewport().set_input_as_handled()
