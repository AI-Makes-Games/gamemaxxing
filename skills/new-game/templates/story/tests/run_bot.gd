extends SceneTree
## Plays the whole story with no window, from the title screen to an ending, and prints
## "RUN COMPLETE: <ending>". By default it takes the first choice every time.
## Run:  godot --headless --path . --script res://tests/run_bot.gd
##       add  -- choice=1        to take the second choice every time
##       add  -- choices=2,0,0   to take these choices in order (then the first choice)

const MAX_FRAMES := 3000

var main: Node
var world: Node2D
var f := 0
var phase := "title"
var end_frame := 0
var choice := 0
var plan: Array = []
var timer_tested := false

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
		print("RUN FAILED: ran out of time (frame %d, scene %s)" % [f, str(world.last_scene) if world != null else "-"])
		quit(1)
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
			# a countdown on this choice (timed_choices on): let it run out once, to test what happens then
			if world.time_left > 0.0 and not timer_tested:
				timer_tested = true
				for i in 60 * 120:
					world.tick(1.0 / 60.0)
					if world.time_left <= 0.0:
						break
				print("(countdown ran out; the game picked a choice by itself)")
				return false
			if world.is_talking() and f % 2 == 0:
				var n: int = world.talking.opts.size() if world.talking.phase == "text" else 0
				var want := choice
				if n > 0 and plan.size() > 0:
					want = plan.pop_front()
				world.choose(clampi(want, 0, max(n - 1, 0)))
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
