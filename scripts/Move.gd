extends RigidBody

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var path = []

var offset_x = 0
var offset_z = 0

var pathIndex = 0
var velocity = Vector3.ZERO
var force = 0
var speed = 0
var acceleration = Vector3.ZERO

var x = 0
var z = 0
var dir = 0

var crossRoadsDirectionOptions = [
	[0, 1, 3],
	[0, 1, 2],
	[1, 2, 3],
	[0, 2, 3]
]

var xPos = 0
var zPos = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	self.pathIndex = 0
	self.path = []
	self.velocity = Vector3.ZERO
	self.x = 0
	self.z = 0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if pathIndex == len(path)-1:
		path.invert()
	if len(Globals.roads) > 0 and len(path) == 0:
		generatePath()


func _physics_process(var delta):
	if len(path) == 10000:
#		if velocity.x > 0.5:
#			xPos = 0.3
#		elif velocity.x < -0.5:
#			xPos = -0.3
#		else:
#			xPos = 0
#
#		if velocity.z > -0.5:
#			zPos = -0.3
#		elif velocity.z < -0.5:
#			zPos = 0.3

		force = followPath()
		acceleration = force / 0.5
		velocity += acceleration * delta
		speed = velocity.length()
		
		if speed > 0:
			velocity = velocity.limit_length(1)
			transform.origin += velocity * delta
			transform.origin.y = 0
			apply_impulse(velocity.rotated(Vector3.UP, rotation.y), Vector3.ZERO)

		var tempUp = transform.basis.y.linear_interpolate(Vector3.UP + (acceleration * 0.1), delta * 5.0)
		look_at(global_transform.origin - velocity, tempUp)

# here dir can be 0, 2, 3 or 3 which equals
# right, down, left or up

func generatePath():
	var firstRoad = Globals.roads[Vector2(x, z)]
	
	while firstRoad == 15:
		x = clamp(x+1, 0, 29)
		firstRoad = Globals.roads[Vector2(x, z)]

#	if firstRoad in Globals.verticalRoads:
##		dir = 2
##
#	path.append(Vector3(-29 + (x*2), 0, -29 + (z*2)))

	for i in range(10000):

		var nextRoad = Globals.roads[Vector2(x, z)]

		path.append(Vector3(-29 + (x*2) + offset_x, 0, -29 + (z*2) + offset_z))
		offset_x = 0
		offset_z = 0

		match nextRoad:
			0: # crossroads
				randomize()
				var num = randi()%3
				dir = crossRoadsDirectionOptions[dir][num]
				
				if dir == 0:
					offset_z = -0.3
				elif dir == 2:
					offset_z = 0.3

				if dir == 1:
					offset_x = 0.3
				elif dir == 3:
					offset_x = -0.3
				
			1: # t junction road down
				randomize()
				if dir == 0: # right or down
					dir = 0 if randi()%2 == 0 else 1
					offset_x = 0.3
					offset_z = -0.3
				elif dir == 2: # left or down
					dir = 2 if randi()%2 == 0 else 1
					offset_x = 0.3
					offset_z = 0.3
				elif dir == 3: # right or left
					var rand = randi()%2
					dir = 0 if rand == 0 else 2
					offset_x = -0.3
					offset_z = -0.3 if rand == 0 else 0.3
			2: # t junction road left
				if dir == 0: # down or up
					var rand = randi()%2
					dir = 1 if rand == 0 else 3
					offset_x = 0.3 if rand == 0 else -0.3
					offset_z = -0.3
				elif dir == 1: # down or left
					dir = 1 if randi()%2 == 0 else 2
					offset_x = 0.3
					offset_z = 0.3
				elif dir == 3: # up or left
					dir = 3 if randi()%2 == 0 else 2
					offset_x = -0.3
					offset_z = 0.3
			3: # top right curved road:
				dir = 1 if dir == 0 else 2
				offset_x = 0.3 if dir == 1 else -0.3
				offset_z = -0.3 if dir == 1 else 0.3
			4: # t junction road up
				if dir == 0: # right or up
					dir = 0 if randi()%2 == 0 else 3
					offset_x = -0.3
					offset_z = -0.3
				elif dir == 1: # left or right
					var rand = randi()%2
					dir = 2 if rand == 0 else 0
					offset_x = 0.3
					offset_z = 0.3 if rand == 0 else -0.3
				elif dir == 2: # left or up
					dir = 2 if randi()%2 == 0 else 3
					offset_x = -0.3
					offset_z = 0.3
			5: # horizontal road
				dir = 0 if dir == 0 else 2
				offset_z = -0.3 if dir == 0 else 0.3
			6: # bottom right curved road
				dir = 3 if dir == 0 else 2
				offset_x = -0.3 if dir == 3 else 0.3
				offset_z = -0.3 if dir == 3 else 0.3
			7: # right dead end road
				dir = 2
			8: # t junction road right
				if dir == 1: # right or down
					dir = 0 if randi()%2 == 0 else 1
					offset_x = 0.3
					offset_z = -0.3
				elif dir == 2: # down or up
					var rand = randi()%2
					dir = 1 if rand == 0 else 3
					offset_x = 0.3 if rand == 0 else -0.3
					offset_z = 0.3
				elif dir == 3: # up or right
					dir = 3 if randi()%2 == 0 else 0
					offset_x = -0.3
					offset_z = -0.3
			9: # top left road curved road
				dir = 0 if dir == 3 else 1
				offset_x = -0.3 if dir == 0 else 0.3
				offset_z = -0.3 if dir == 0 else 0.3
			10: # vertical road
				dir = 1 if dir == 1 else 3
				offset_x = 0.3 if dir == 1 else -0.3
			11: # top dead end road
				dir = 1
			12: # bottom left curved road
				dir = 0 if dir == 1 else 3
				offset_x = 0.3 if dir == 0 else -0.3
				offset_z = -0.3 if dir == 0 else 0.3
			13: # left dead end road
				dir = 0
			14: # bottom dead end road
				dir = 3
		
		match dir:
			0: x+=1
			1: z+=1
			2: x-=1
			3: z-=1
		x = clamp(x, 0, 29)
		z = clamp(z, 0, 29)

func followPath():
	var target = path[pathIndex]
#	+Vector3(0, 0, 1)
	var dist = global_transform.origin.distance_to(target)
	if dist < 0.5:
		pathIndex = (pathIndex + 1) % len(path)
	
	return seek(path[pathIndex])

func seek(target: Vector3):
	var toTarget = target - transform.origin
	toTarget = toTarget.normalized()
	var desired = toTarget * 2
	return desired - velocity
