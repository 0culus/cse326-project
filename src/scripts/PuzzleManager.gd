const DIFF_EASY		= 0
const DIFF_MEDIUM	= 1
const DIFF_HARD		= 2

const BLOCK_LASER	= 0
const BLOCK_WILD	= 1
const BLOCK_PAIR	= 2
const BLOCK_GOAL	= 3

const blockColors = ["Blue", "Orange", "Red", "Yellow", "Purple", "Green"]

# Preload paired blocks
const blocks = { PairedBlock = preload("Blocks/PairedBlock.gd")
			   , LaserBlock  = preload("Blocks/LaserBlock.gd")
			   , FlyBlock    = preload("Blocks/FlyawayTestBlock.gd")
			   , blockScn    = preload( "res://blocks/block.scn" )
			   }

# Stores a puzzle in a convenient class.
class Puzzle:
	var puzzleLayers
	var blocks = []

# Holds all of the steps needed to solve a puzzle.
class PuzzleSteps:
	var solveable

# Randomly shuffle an array.
func shuffleArray( arr ):
	for i in range( arr.size() - 1, 1, -1 ):
		# works great! print( "SWAP" )
		var swapVal = randi() % (i + 1)
		var temp = arr[swapVal]
		arr[swapVal] = arr[i]
		arr[i] = temp

# Determines the block type based on puzzle size and difficulty.
func getBlockType( difficulty, x, y, z ):
	# Determine if this is the goal block.
	if x == 0 and y == 0 and z == 0:
		return BLOCK_GOAL
	
	# Determine the layer this block is on.
	var layer = max( max( abs( x ), abs( y ) ), abs( z ) )
		
	# Determine how many blocks are on the outer part of the layer.
	var layerCount = 0
	if abs( x ) == layer:
		layerCount += 1
	if abs( y ) == layer:
		layerCount += 1
	if abs( z ) == layer:
		layerCount += 1
		
	# Determine if this block is a laser.
	if difficulty == DIFF_EASY or difficulty == DIFF_MEDIUM:
		if layerCount == 3:
			return BLOCK_LASER
			
	if difficulty == DIFF_HARD:
		if abs( x ) == abs( z ) and y == 0:
			return BLOCK_LASER
			
	# Determine if this block is a wild block.
	if difficulty == DIFF_EASY:
		if layerCount == 2:
			return BLOCK_WILD
			
	if difficulty == DIFF_MEDIUM:
		if layerCount == 2:
			if y == layer || y == -layer:
				return BLOCK_WILD
				
	if difficulty == DIFF_HARD:
		if layerCount == 1:
			if y == 0:
				return BLOCK_WILD
		
	# Otherwise it's a normal block.
	return BLOCK_PAIR

# Generates a solveable puzzle.
func generatePuzzle( layers, difficulty ):
	var blockID = 0
	var puzzle = Puzzle.new()
	puzzle.puzzleLayers = layers
	
	# Calculate puzzle size.
	#var puzzSize = layers + 2
	#var middle = puzzSize / 2

	# Create all possible positions.
	var pairblocks = []
	var lasers = []
	var wildblocks = []
	for x in range( -layers, layers + 1 ):
		for y in range( -layers, layers + 1 ):
			for z in range( -layers, layers + 1 ):
				pairblocks.append(Vector3(x,y,z))

	# Assign lasers.

	# assign blocks to positions
	var prevBlock = null
	var even = false
	for pos in pairblocks:
		var x = pos.x
		var y = pos.y
		var z = pos.z
#		if (x == middle && y == middle && z == middle):
#			continue

		var t = getBlockType( difficulty, x, y, z )
		
		if t == BLOCK_GOAL or t == BLOCK_WILD:
			continue

		var b = PickledBlock.new()
		b.blockPos = pos
		b.name = "block" + str(blockID)

		blockID += 1
		puzzle.blocks.append( b )

		if t == BLOCK_LASER:
			b.setBlockClass("LaserBlock")
			continue

		if even:
			var randColor = blockColors[randi() % blockColors.size()]
			b.setBlockClass("PairedBlock") \
				.setPairName(prevBlock.name) \
				.setTextureName(randColor)

			prevBlock.setBlockClass("PairedBlock") \
				.setPairName(b.name) \
				.setTextureName(randColor)
		even = not even
		prevBlock = b



	# TODO, proposed algorithm:
	# make blocks, pairs are adjacent
	# shuffle board, half the blocks pick a "nearby" block to swap places with
	# nearby = same layer, somewhere accessible to the user

	# Randomize the order of the blocks.
#	self.shuffleArray( puzzle.blocks )

	# Assign block types in pairs.
#	for i in range( 0, puzzle.blocks.size(), 2 ):
#		var randColor = blockColors[randi() % blockColors.size()]
#		puzzle.blocks[i].setBlockClass("PairedBlock") \
#			.setPairName(puzzle.blocks[i+1].name) \
#			.setTextureName(randColor)
#
#		puzzle.blocks[i+1].setBlockClass("PairedBlock") \
#			.setPairName(puzzle.blocks[i].name) \
#			.setTextureName(randColor)

	return puzzle

# Determines if a puzzle is solveable.
func solvePuzzle( puzzle ):
	# Simply use the solvePuzzleSteps function and return the solveable part.
	var ps = solvePuzzleSteps()
	return ps.solveable

# Determines if a puzzle is solveable and returns the steps needed to solve it.
func solvePuzzleSteps( puzzle ):
	var puzzleSteps = PuzzleSteps.new()
	puzzleSteps.solveable = true

	# SOLVER

	return puzzleSteps


# efficient representation of blocks. toNode() generates an actual game object
class PickledBlock:
	var name
	var blockClass
	var pairName
	var textureName
	var blockPos

	func setName(n):
		name = n
		return self

	func setPairName(n):
		pairName = n
		return self

	func setBlockClass(c):
		blockClass = c
		return self

	func setTextureName(t):
		textureName = t
		return self

	func toString():
		return str(name) + ": " + str(blockClass)

	func toNode(gen):
		# instantiate a block scene, assign the appropriate script to it
		var n = blocks["blockScn"].instance()
		n.set_script(blocks[blockClass])

		# configure block node
		n.setName(name).setTexture()

		if blockClass == "PairedBlock":
			n.setPairName(pairName).setTexture(textureName)
		return n
