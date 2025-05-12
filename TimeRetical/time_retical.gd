class_name  TimeRetical
extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	TimeManager.on_start.connect(TimedSketchManager_on_start)
	TimeManager.on_stop.connect(TimedSketchManager_on_stop)
	visible = false


func TimedSketchManager_on_start():
	activate()

func TimedSketchManager_on_stop():
	deactivate()
		
func activate():
	visible = true

func deactivate():
	visible = false
	
func _process(delta):
	update_progress_bar()
	
	pass

func update_progress_bar():
	var elapsed_time = TimeManager.get_time_elapsed()
	var interval_time = TimeManager.interval_time
	
	$TextureProgressBar.value = (elapsed_time / interval_time)*100
