extends Node

signal on_start()
signal on_timed_next()
signal on_stop()
@export var interval_time := 60
@onready var timer = $Timer
@export var num_images_to_show := 20 
var sketch_count := 0
var image_ui_counter
signal timeout

func start():
	timer.wait_time = interval_time
	sketch_count = 0
	timer.start()
	on_start.emit()
	print(image_ui_counter)
	if image_ui_counter != null:
		image_ui_counter.text = str(sketch_count)	
		image_ui_counter.visible = true	
	#$"../CanvasLayer/Label".text = str(sketch_count)	
	#$"../CanvasLayer".visible = true	

func pause():
	timer.wait_time = interval_time
	sketch_count+=1
	
	if(timer.is_stopped()):return
	if image_ui_counter != null:
		image_ui_counter.text = str(sketch_count)
	#$"../CanvasLayer/Label".text = str(sketch_count)
	timer.start()	
	on_timed_next.emit()
		
func next():
	timer.wait_time = interval_time
	sketch_count+=1
	
	if(timer.is_stopped()):return
	if image_ui_counter != null:
		image_ui_counter.text = str(sketch_count)
	#$"../CanvasLayer/Label".text = str(sketch_count)
	timer.start()	
	on_timed_next.emit()

	
func stop():
	timer.stop()	
	on_stop.emit()
	if image_ui_counter != null:
		image_ui_counter.visible = false	


func get_time_elapsed():
	return timer.wait_time - timer.time_left


func _on_timer_timeout():
	sketch_count+=1
	timeout.emit()
