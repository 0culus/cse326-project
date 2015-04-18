extends "AbstractBlock.gd"

var pairName = null
var selected = false

func setTexture(textureName="Red"):
	var img = Image()
	var mat = FixedMaterial.new()
	var text = ImageTexture.new()

	# TODO preload
	img.load("res://textures/Block_" + textureName + ".png")

	text.create_from_image(img)
	mat.set_texture(FixedMaterial.PARAM_DIFFUSE, text)
	# TODO color the texture: mat.set_parameter(FixedMaterial.PARAM_DIFFUSE, Color(0.5, 0.5, 0))

	self.get_node("MeshInstance").set_material_override(mat)
	return self

func setPairName(other):
	pairName = other
	return self

# fly away only if self.pairName is selected
func activate(ev, click_pos, click_normal, justFly=false):
	selected = true

	# get my pair sibling
	# TODO merge Laser and Paired into an abstract paired class
	var pairNode = get_parent().get_node(str(pairName))
	if pairName == null or not get_parent().has_node(pairName):
		scaleTweenNode(0.9, 0.2, Tween.TRANS_EXPO).start()
		return
		

	if not pairNode.selected:
		scaleTweenNode(1.1, 0.2, Tween.TRANS_EXPO).start()
	else:
		get_parent().samplePlayer.play("deraj_pop_sound_low")
		# fly away
		var tweenNode = newTweenNode()
		tweenNode.interpolate_method( self, "set_translation", \
			self.get_translation(), self.get_translation().normalized() * far_away_corner, \
			1, Tween.TRANS_CIRC, Tween.EASE_IN_OUT )

		tweenNode.start()
		# just one call to activate...
		if not justFly:
			pairNode.activate(ev, click_pos, click_normal, true)
