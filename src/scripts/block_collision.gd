extends RigidBody

var actions
var tween_count = 0
const far_away_corner = Vector3(80, 80, 80)

const ACTION_SCALE = 0
const ACTION_FLY_AWAY = 1
const ALLACTIONS = [ACTION_SCALE, ACTION_FLY_AWAY]

func _input_event( camera, ev, click_pos, click_normal, shape_idx ):
	if (ev.type==InputEvent.MOUSE_BUTTON and ev.button_index==BUTTON_LEFT):
		activate(ev, click_pos, click_normal)	
		
func activate(ev, click_pos, click_normal):
	var tween = Tween.new()
	var tween_name = "tween" + str(tween_count)
	tween.set_name(tween_name)
	add_child(tween)
	tween_count += 1
	var tween_node = get_node(tween_name)
	
	if actions.find(ACTION_SCALE) > -1:
		var s = 0.1
		tween_node.interpolate_method( self, "set_scale", \
			self.get_scale(), Vector3(s, s, s), \
			1, Tween.TRANS_BOUNCE, Tween.EASE_OUT )
			
	if actions.find(ACTION_FLY_AWAY) > -1:
		# Efficient use of Tween?
		tween_node.interpolate_method( self, "set_translation", \
			self.get_translation(), self.get_translation().normalized() * far_away_corner, \
			1, Tween.TRANS_QUAD, Tween.EASE_OUT )
			
	tween_node.start()

func _ready():
	actions = [ ALLACTIONS[rand_range(0, ALLACTIONS.size())] ]

	set_ray_pickable(true)