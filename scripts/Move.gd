extends KinematicBody

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var path = []

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
	[2, 1, 3],
	[1, 0, 2],
	[3, 0, 2]
]

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
	if len(path) == 200:
		force = followPath()
		acceleration = force / 1
		velocity += acceleration * delta
		speed = velocity.length()
		
		if speed > 0:
			velocity = velocity.limit_length(1)
			transform.origin += velocity * delta
			move_and_slide(velocity)

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

	for i in range(200):
#		print(x, " ", z)
		var nextRoad = Globals.roads[Vector2(x, z)]

		path.append(Vector3(-29 + (x*2), 0, -29 + (z*2)))

		match nextRoad:
			0: # crossroads
				randomize()
				var num = randi()%3
				dir = crossRoadsDirectionOptions[dir][num]
			1: # t junction road down
				randomize()
				if dir == 0: # right or down
					dir = 0 if randi()%2 == 0 else 1
				elif dir == 2: # left or down
					dir = 2 if randi()%2 == 0 else 1
				elif dir == 3: # right or left
					dir = 0 if randi()%2 == 0 else 2
			2: # t junction road left
				if dir == 0: # down or up
					dir = 1 if randi()%2 == 0 else 3
				elif dir == 1: # down or left
					dir = 1 if randi()%2 == 0 else 2
				elif dir == 3: # up or left
					dir = 3 if randi()%2 == 0 else 2
			3: # top right curved road:
				dir = 1 if dir == 0 else 2
			4: # t junction road up
				if dir == 0: # right or up
					dir = 0 if randi()%2 == 0 else 3
				elif dir == 1: # left or right
					dir = 2 if randi()%2 == 0 else 0
				elif dir == 2: # left or up
					dir = 2 if randi()%2 == 0 else 3
			5: # horizontal road
				dir = 0 if dir == 0 else 2
			6: # bottom right curved road
				dir = 3 if dir == 0 else 2
			7: # right dead end road
				dir = 2
			8: # t junction road right
				if dir == 1: # right or down
					dir = 0 if randi()%2 == 0 else 1
				elif dir == 2: # down or up
					dir = 1 if randi()%2 == 0 else 3
				elif dir == 3: # up or right
					dir = 3 if randi()%2 == 0 else 0
			9: # top left road
				dir = 0 if dir == 3 else 1
			10: # vertical road
				dir = 1 if dir == 1 else 3 
			11: # top dead end road
				dir = 1
			12: # bottom left curved road
				dir = 0 if dir == 1 else 3
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
	var dist = global_transform.origin.distance_to(target)
	
	if dist < 1:
		pathIndex = (pathIndex + 1) % len(path)
	
	return seek(path[pathIndex])

func seek(target: Vector3):
	var toTarget = target - transform.origin
	toTarget = toTarget.normalized()
	var desired = toTarget * 2
	return desired - velocity
