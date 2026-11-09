## Runs the game's screens in order: the title, then the game, then the ending, then back to the title.
extends Node

const Data := preload("res://scripts/data.gd")
const UI := preload("res://scripts/ui.gd")
const World := preload("res://scripts/world.gd")

var D: RefCounted
var world: Node = null
var screen: Control = null
var screen_name := ""
var ending_id := ""
var layer: CanvasLayer

func _ready() -> void:
	D = Data.new()
	D.load_all()
	if DisplayServer.get_name() != "headless":
		DisplayServer.window_set_title(str(D.game.get("title", "My Game")))
	RenderingServer.set_default_clear_color(D.colour("background", "#1d2330"))
	layer = CanvasLayer.new()
	layer.layer = 10
	add_child(layer)
	show_title()

func _clear() -> void:
	if world != null:
		world.queue_free()
		world = null
	if screen != null:
		screen.queue_free()
		screen = null

func show_title() -> void:
	_clear()
	screen = UI.title_screen(D, start_game)
	layer.add_child(screen)
	screen_name = "title"

func start_game() -> void:
	_clear()
	world = World.new()
	world.setup(D)
	world.finished.connect(_on_finished)
	add_child(world)
	screen_name = "game"

func _on_finished(ending: Dictionary, recap: Array) -> void:
	ending_id = str(ending.get("id", ""))
	call_deferred("_show_ending", ending, recap)

func _show_ending(ending: Dictionary, recap: Array) -> void:
	_clear()
	screen = UI.ending_screen(D, ending, recap, show_title)
	layer.add_child(screen)
	screen_name = "ending"
