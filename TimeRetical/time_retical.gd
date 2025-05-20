class_name  TimeRetical
extends Control

var percentage_of_time
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
	if TimeManager.timer.get_time_left() >0:
		percentage_of_time = (1 -  float(TimeManager.timer.get_time_left()) /  TimeManager.timer.get_wait_time())
		$ProgressBar.value = percentage_of_time
