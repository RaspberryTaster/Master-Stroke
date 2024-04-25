extends Line2D

var start_point : Vector2
var dragging : bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	print()
 
func _input(event):
	if event.is_action_pressed("left_click"):
		start_point = get_viewport().get_mouse_position()
		points = [start_point,start_point]
		print("pressed at ", event.position)
		#print("viewport pressed at", get_viewport().get_mouse_position())
		dragging = true
		
	if (event is InputEventMouseMotion) and dragging:
		print(get_viewport().get_mouse_position())
		points[1] = event.position
		
	if event.is_action_released("left_click"):
		print("release at ", event.position)
		dragging = false
