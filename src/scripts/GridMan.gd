extends Spatial

# Is there a better way to do this?
const BLOCK_LASER	= 0
const BLOCK_WILD	= 1
const BLOCK_PAIR	= 2
const BLOCK_GOAL	= 3
const BLOCK_BLOCK   = 4

# Shape dictionary to access blocks quickly by position.
var shape = {}

# Block selection handling.
var offClick = false
var selectedBlocks = []

# Puzzle vars.
var pairCount = []

# sounds
var samplePlayer = SamplePlayer.new()

func add_block(b):
	shape[b.blockPos] = b
	add_child(b)

func get_block(pos):
	if shape.has(pos):
		return shape[pos]
	else:
		return null

func remove_block(block_node):
	shape[block_node.blockPos] = null
	# TODO scan_layer, fire lasers if empty
	for child in block_node.get_children():
		block_node.remove_and_delete_child(child)
	remove_and_delete_child(block_node)

# TODO wild block selected? can click any pair. can deselect wild block.
var wildBlockSelected = null

# Sets the puzzle for this GridMan.
func set_puzzle(puzzle):
	#puzzle = puzzle ???
	# Initalization here
	samplePlayer.set_voice_count(puzzle.puzzleLayers * 2)
	samplePlayer.set_sample_library(ResourceLoader.load("new_samplelibrary.xml"))
	
	# Set the camera range to be relative to the layer count.
	var cam = get_parent().get_parent().get_node( "Camera" )
	var totalSize = ( puzzle.puzzleLayers * 2 + 1 )
	cam.distance.val = 3.2 * totalSize
	cam.distance.min_ = 3 * totalSize
	cam.distance.max_ = 10 * totalSize
	cam.recalculate_camera()
	
	# Gather important info from the puzzle.
	pairCount = [] + puzzle.pairCount	# Make a copy, don't use the same array.
	
# Clears any selected blocks. WE SHOULD FIX THIS, THERE CAN ONLY BE ONE BLOCK SELECTED AT ANY ONE TIME, NO NEED FOR AN ARRAY!
func clearSelection():
	for bl in selectedBlocks:
		var blo = get_node( bl )
		blo.setSelected(false)
		blo.scaleTweenNode(1.0).start()
	selectedBlocks = []
	
# Add the selected block to the selected list. WE SHOULD FIX THIS, IT ONLY NEEDS TO STORE IT, NOT AN ARRAY!
func addSelected(bl):
	selectedBlocks.append(bl)

# Calculates the layer that a block is on.
# COPY OF FUNCTION IN PUZZLEMAN, IS THERE A BETTER WAY TO DO THIS?!
func calcBlockLayer( x, y, z ):
	return max( max( abs( x ), abs( y ) ), abs( z ) )

# Handles keeping track of pairs being removed.
func popPair( pos ):
	var blayer = calcBlockLayer( pos.x, pos.y, pos.z )
	pairCount[blayer] -= 1
	print( blayer, " ", pairCount[blayer] )
	if( pairCount[blayer] == 0 ):
		for b in shape:
			if not ( shape[b] == null ):
				if shape[b].getBlockType() == BLOCK_LASER:
					shape[b].activate()
		
