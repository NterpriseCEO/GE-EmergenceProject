class_name BoidMovement extends RigidBody

enum ForceDirection {Normal, Incident, Up, Braking}
export var direction = ForceDirection.Normal
export var feeler_angle = 60
export var feeler_length = 1
export var updates_per_second = 10

var center_offset = 0.3
var velocity_length = 10

var feelers = []
var space_state: PhysicsDirectSpaceState

var needsUpdating = true

var path = []

var offset_x = 0
var offset_z = 0

var pathIndex = 0
var velocity = Vector3.ZERO
var force = Vector3.ZERO
var maxForce = 7
var forceMultiplier = 1
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
var startPos

# Called when the node enters the scene tree for the first time.
func _ready():
	self.pathIndex = 0
	self.path = []
	self.velocity = Vector3.ZERO

	self.x = 15
	self.z = 15

	# Sets the boid position to the ceneter of the map
	translation = Vector3(offset_x, 0, offset_z)

	space_state = self.get_world().direct_space_state
	
	var timer = Timer.new()
	add_child(timer)	
	timer.wait_time = 1.0 / updates_per_second
	timer.connect("timeout", self, "needs_updating")
	timer.start()


func needs_updating():
	needsUpdating = true

func draw_gizmos():
	for feeler in feelers:

		if feeler.hit:
			DebugDraw.draw_line(self.global_transform.origin, feeler.hit_target, Color.chartreuse)
			DebugDraw.draw_arrow_line(feeler.hit_target, feeler.hit_target + feeler.force, Color.red, 0.1)
		else:
			DebugDraw.draw_line(Vector3(0, 1, 0), Vector3(3, 1, 0), Color.chartreuse)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
#	draw_gizmos()
	# Reverses the path when the end of the path is met
	if pathIndex == len(path)-1:
		path.invert()
	if len(Globals.roads) > 0 and len(path) == 0:
		generatePath()


func _physics_process(var delta):
	if len(path) == 10000:
		force = followPath()*3
		
#		update_feelers()

		force = force.limit_length(maxForce)

		acceleration = force / 0.5
		velocity += acceleration * delta
		speed = velocity.length()


		if speed > 0:
			velocity = velocity.limit_length(velocity_length)
			transform.origin += velocity * delta*forceMultiplier
			transform.origin.y = 0
			apply_impulse(velocity.rotated(Vector3.UP, rotation.y)*forceMultiplier, Vector3.ZERO)

		var tempUp = transform.basis.y.linear_interpolate(Vector3.UP + (acceleration * 0.1), 0.1)
		look_at(global_transform.origin - velocity*0.1, tempUp)

# Couldn't get this to work with the boids
func feel(local_ray):
	var feeler = {}
	var ray_end = self.global_transform.xform(local_ray)
	var result = space_state.intersect_ray(self.global_transform.origin, ray_end, [self], self.collision_mask)
	feeler.end = ray_end
	feeler.hit = result
	if result:
		feeler.hit_target = result.position
		feeler.normal = result.normal
		var to_boid = self.global_transform.origin - result.position 
		var force_mag = ((feeler_length - to_boid.length()) / feeler_length)
		match direction:
			ForceDirection.Normal:
				feeler.force = result.normal * force_mag
			ForceDirection.Incident:
				feeler.force = to_boid.reflect(result.normal).normalized() * force_mag
			ForceDirection.Up:
				feeler.force = Vector3.UP * force_mag
			ForceDirection.Braking:
				feeler.force = to_boid.normalized() * force_mag
		force += feeler.force
		force.y = 0
	return feeler


func update_feelers():
	force = Vector3.ZERO
	feelers.clear()
	var forwards = Vector3.BACK * feeler_length
	feelers.push_back(feel(forwards))
	feelers.push_back(feel(Quat(Vector3.UP, deg2rad(feeler_angle)) * forwards))
	feelers.push_back(feel(Quat(Vector3.UP, deg2rad(-feeler_angle)) * forwards))

	feelers.push_back(feel(Quat(Vector3.RIGHT, deg2rad(feeler_angle)) * forwards))
	feelers.push_back(feel(Quat(Vector3.RIGHT, deg2rad(-feeler_angle)) * forwards))


# Here dir can be 0, 1, 2 or 3 which equals
# right, down, left or up
# Offset refers to the position on the road i.e left side or right side
func generatePath():
	var firstRoad = Globals.roads[Vector2(x, z)]

	# Loops until a non empty tile is found
	while firstRoad == 15:
		x = clamp(x+1, 0, 29)
		firstRoad = Globals.roads[Vector2(x, z)]

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
					offset_z = -center_offset
				elif dir == 2:
					offset_z = center_offset

				if dir == 1:
					offset_x = center_offset
				elif dir == 3:
					offset_x = -center_offset
				
			1: # t junction road down
				randomize()
				if dir == 0: # right or down
					dir = 0 if randi()%2 == 0 else 1
					offset_x = center_offset
					offset_z = -center_offset
				elif dir == 2: # left or down
					dir = 2 if randi()%2 == 0 else 1
					offset_x = center_offset
					offset_z = center_offset
				elif dir == 3: # right or left
					var rand = randi()%2
					dir = 0 if rand == 0 else 2
					offset_x = -center_offset
					offset_z = -center_offset if rand == 0 else center_offset
			2: # t junction road left
				if dir == 0: # down or up
					var rand = randi()%2
					dir = 1 if rand == 0 else 3
					offset_x = center_offset if rand == 0 else -center_offset
					offset_z = -center_offset
				elif dir == 1: # down or left
					dir = 1 if randi()%2 == 0 else 2
					offset_x = center_offset
					offset_z = center_offset
				elif dir == 3: # up or left
					dir = 3 if randi()%2 == 0 else 2
					offset_x = -center_offset
					offset_z = center_offset
			3: # top right curved road:
				dir = 1 if dir == 0 else 2
				offset_x = center_offset if dir == 1 else -center_offset
				offset_z = -center_offset if dir == 1 else center_offset
			4: # t junction road up
				if dir == 0: # right or up
					dir = 0 if randi()%2 == 0 else 3
					offset_x = -center_offset
					offset_z = -center_offset
				elif dir == 1: # left or right
					var rand = randi()%2
					dir = 2 if rand == 0 else 0
					offset_x = center_offset
					offset_z = center_offset if rand == 0 else -center_offset
				elif dir == 2: # left or up
					dir = 2 if randi()%2 == 0 else 3
					offset_x = -center_offset
					offset_z = center_offset
			5: # horizontal road
				dir = 0 if dir == 0 else 2
				offset_z = -center_offset if dir == 0 else center_offset
			6: # bottom right curved road
				dir = 3 if dir == 0 else 2
				offset_x = -center_offset if dir == 3 else center_offset
				offset_z = -center_offset if dir == 3 else center_offset
			7: # right dead end road
				dir = 2
			8: # t junction road right
				if dir == 1: # right or down
					dir = 0 if randi()%2 == 0 else 1
					offset_x = center_offset
					offset_z = -center_offset
				elif dir == 2: # down or up
					var rand = randi()%2
					dir = 1 if rand == 0 else 3
					offset_x = center_offset if rand == 0 else -center_offset
					offset_z = center_offset
				elif dir == 3: # up or right
					dir = 3 if randi()%2 == 0 else 0
					offset_x = -center_offset
					offset_z = -center_offset
			9: # top left road curved road
				dir = 0 if dir == 3 else 1
				offset_x = -center_offset if dir == 0 else center_offset
				offset_z = -center_offset if dir == 0 else center_offset
			10: # vertical road
				dir = 1 if dir == 1 else 3
				offset_x = center_offset if dir == 1 else -center_offset
			11: # top dead end road
				dir = 1
			12: # bottom left curved road
				dir = 0 if dir == 1 else 3
				offset_x = center_offset if dir == 0 else -center_offset
				offset_z = -center_offset if dir == 0 else center_offset
			13: # left dead end road
				dir = 0
			14: # bottom dead end road
				dir = 3
		# Path is generated in a given direction
		# based on the direction calculated above
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
	if dist < 0.5:
		pathIndex = (pathIndex + 1) % len(path)
	
	return seek(path[pathIndex])

# Seeks the next path that a boid is supposed to move towards
func seek(target: Vector3):
	var toTarget = target - transform.origin
	toTarget = toTarget.normalized()
	var desired = toTarget * 2

	return desired - velocity


# Slows down boids when they are close to colliding with other boids
func _on_Area_body_entered(body):
	forceMultiplier = 0.1


func _on_Area_body_exited(body):
	forceMultiplier = 1


func _on_Area_area_entered(area):
	forceMultiplier = 0.1


func _on_Area_area_exited(area):
	forceMultiplier = 1


func _on_Area_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	forceMultiplier = 0.1


func _on_Area_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	forceMultiplier = 1
