extends "AbstractBlock.gd"

# Is there a better way to do this?
const BLOCK_LASER	= 0
const BLOCK_WILD	= 1
const BLOCK_PAIR	= 2
const BLOCK_GOAL	= 3
const BLOCK_BLOCK   = 4

var textureName

func setTexture(textureName="Red"):
	var img = Image()
	self.textureName = textureName

	# TODO preload
	var mat = load("res://materials/block_" + textureName + ".mtl")

	# TODO color the texture: mat.set_parameter(FixedMaterial.PARAM_DIFFUSE, Color(0.5, 0.5, 0))

	self.get_node("MeshInstance").set_material_override(mat)
	return self
	
# Animate the removal of this block and its pair.
func popBlock( pairNode, justFly = false ):
	get_parent().samplePlayer.play("deraj_pop_sound_low")
	# fly away
	var tweenNode = newTweenNode()
	tweenNode.interpolate_method( self, "set_translation", \
		self.get_translation(), self.get_translation().normalized() * far_away_corner, \
		1, Tween.TRANS_CIRC, Tween.EASE_IN_OUT )

	tweenNode.start()
	# just one call to activate...
	if not justFly:
		pairNode.activate(true)

# fly away only if self.pairName is selected
func activate(justFly=false):
	var gridView = get_parent().get_parent()

	if gridView.selectedBlocks.size() > 0:
		var selBlock = gridView.get_node( "GridMan" ).get_node( gridView.selectedBlocks[0] )
		
		if selBlock.getBlockType() == BLOCK_WILD:
			if selBlock.textureName == textureName:
				gridView.clearSelection()
				selBlock.popBlock()
				forceActivate()
				return

	var pairNode = pairActivate()
	if pairNode == null:
		return
	if pairNode.selected:
		popBlock( pairNode, justFly )
			
# Force the pair to activate.
func forceActivate():
	var pairNode = pairActivate()
	if pairNode == null:
		return
		
	popBlock( pairNode )
	
