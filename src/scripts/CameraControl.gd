# Make this work on touch:
# catch InputEventScreenDrag, InputEventScreenTouch
#   write two-finger zoom

# camera function that uses the mouse wheel to zoom
extends Camera


# global working variables
var turn = Vector2( 0.0, 0.0 )            # the amount the mouse has turned
var mouseposlast = Input.get_mouse_pos()   # the mouses last position
var pos = Vector3(0.0,0.0,0.0)            # the position of the camera
var up = Vector3(0.0,1.0,0.0)            # the normalized 'up' vector pointing vertically
var target = Vector3(0.0,0.0,0.0)         # the look at target


# global tweakable parameters
var distance = { val = 16.0, max_ = 50, min_ = 15 }
var zoom_rate = 100            # the rate at which the camera zooms in and out of the target
var orbitrate = 20        # the rate the camera orbits the target when the mouse is moved
var target_move_rate = 1.0      # the rate the target look at point moves


# called once after node is setup
func _ready():
	set_process_input(true)      # process user input events here
	# Input.set_mouse_mode(2)      # mouse mode captured


# Repositions the camera based on the zoom level.
func recalculate_camera():
	pos = get_translation();
	pos.z = distance.val;
	set_translation( pos )


# called to handle a user input event
func _input(ev):
   # if the user spins the mouse wheel up move the camera closer
	if (ev.type==InputEvent.MOUSE_BUTTON and ev.button_index==BUTTON_WHEEL_UP):
		if (distance.val > distance.min_):
			distance.val -= zoom_rate * get_process_delta_time()
   # if the user spins the mouse wheel down move the camera farther away
	elif (ev.type==InputEvent.MOUSE_BUTTON and ev.button_index==BUTTON_WHEEL_DOWN):
		if (distance.val < distance.max_):
			distance.val += zoom_rate * get_process_delta_time()
   # if a cancel action is input close the application
	elif (ev.is_action("ui_cancel")):
		#OS.get_main_loop().quit()
		print("caught exit action!")
		var exit = load("res://scripts/ExitDialog.gd").new()
		exit.show_dialog()
	else:
		return

	recalculate_camera()

