## One thing on screen: the player, a character, a creature, an item, a door or the goal.
## Shows its art if there is some (see sprite_bank.gd), otherwise draws a simple shape.
extends Node2D

const SB := preload("res://scripts/sprite_bank.gd")

var sprite_id := ""
var color := Color.WHITE
var shape := "circle"      # circle, blob, square, diamond, star, door, flag, sign
var size := 26.0
var label := ""
var face := Vector2.RIGHT
var state := "idle"
var flash := 0.0
var open := false          # doors
var spr: AnimatedSprite2D = null

func setup(id: String, col: Color, shp: String, sz: float, name_label := "") -> Node2D:
	sprite_id = id
	color = col
	shape = shp
	size = sz
	label = name_label
	return self

func _ready() -> void:
	var f := SB.frames(sprite_id)
	if f != null:
		spr = AnimatedSprite2D.new()
		spr.sprite_frames = f
		spr.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var anim := SB.pick(f, "idle")
		spr.play(anim)
		var tex := f.get_frame_texture(anim, 0)
		if tex != null:
			var h := float(tex.get_height())
			spr.scale = Vector2.ONE * (size * 2.0 / max(h, 1.0))
			# stand the art on its feet: the bottom of the picture sits where the shape's bottom would be
			spr.position = Vector2(0, size / 2.0 - h * spr.scale.y / 2.0)
		add_child(spr)

func show_state(s: String, facing: Vector2) -> void:
	state = s
	if facing.length() > 0.1:
		face = facing
	if spr != null:
		var anim := SB.pick(spr.sprite_frames, s)
		if spr.animation != anim:
			spr.play(anim)
		if absf(face.x) > 0.1:
			spr.flip_h = face.x < 0
	modulate = Color(1.0, 0.45, 0.45) if flash > 0.0 else Color.WHITE
	queue_redraw()

func _draw() -> void:
	if label != "":
		var font := ThemeDB.fallback_font
		var w := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, 13).x
		draw_string(font, Vector2(-w / 2.0, -size - 8), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(1, 1, 1, 0.85))
	if spr != null:
		return
	var r := size / 2.0
	var dark := color.darkened(0.45)
	match shape:
		"circle":
			draw_circle(Vector2.ZERO, r, color)
			draw_arc(Vector2.ZERO, r, 0, TAU, 24, dark, 2.0)
			_eyes(r)
		"blob":
			draw_set_transform(Vector2(0, r * 0.2), 0, Vector2(1.2, 0.8))
			draw_circle(Vector2.ZERO, r, color)
			draw_set_transform(Vector2.ZERO)
			_eyes(r * 0.8)
		"square":
			draw_rect(Rect2(-r, -r, r * 2, r * 2), color)
			draw_rect(Rect2(-r, -r, r * 2, r * 2), dark, false, 2.0)
			_eyes(r)
		"diamond":
			draw_colored_polygon(PackedVector2Array([Vector2(0, -r), Vector2(r * 0.7, 0), Vector2(0, r), Vector2(-r * 0.7, 0)]), color)
		"star":
			var pts := PackedVector2Array()
			for i in 10:
				pts.append(Vector2.from_angle(-PI / 2 + i * PI / 5) * (r if i % 2 == 0 else r * 0.45))
			draw_colored_polygon(pts, color)
		"door":
			if open:
				draw_rect(Rect2(-r, -r, r * 2, r * 0.3), dark)
			else:
				draw_rect(Rect2(-r, -r, r * 2, r * 2), color)
				for i in 3:
					draw_line(Vector2(-r + (i + 1) * r * 0.5, -r), Vector2(-r + (i + 1) * r * 0.5, r), dark, 2.0)
				draw_circle(Vector2(r * 0.55, 0), 3, Color(1, 0.85, 0.3))
		"sign":
			draw_line(Vector2(0, r), Vector2(0, -r * 0.2), dark, 4.0)
			draw_rect(Rect2(-r, -r, r * 2, r * 0.9), color)
			draw_rect(Rect2(-r, -r, r * 2, r * 0.9), dark, false, 2.0)
		"flag":
			draw_line(Vector2(-r * 0.4, r), Vector2(-r * 0.4, -r), dark, 3.0)
			draw_colored_polygon(PackedVector2Array([Vector2(-r * 0.4, -r), Vector2(r * 0.8, -r * 0.6), Vector2(-r * 0.4, -r * 0.2)]), color)
		_:
			draw_circle(Vector2.ZERO, r, color)

func _eyes(r: float) -> void:
	var f := face.normalized() if face.length() > 0.1 else Vector2.RIGHT
	var side := Vector2(-f.y, f.x) * r * 0.35
	var c := f * r * 0.35
	draw_circle(c + side, r * 0.14, Color(0.1, 0.1, 0.12))
	draw_circle(c - side, r * 0.14, Color(0.1, 0.1, 0.12))
