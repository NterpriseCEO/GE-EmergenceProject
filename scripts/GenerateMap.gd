extends Spatial
# Adapted and improved: https://kidscancode.org/blog/2018/09/godot3_procgen2/
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var roads = {}

var road_instances = []

const N = 1
const E = 2
const S = 4
const W = 8

var size = 30;
var cell_walls = {
	Vector2(0, -2): N,
	Vector2(2, 0): E,
	Vector2(0, 2): S,
	Vector2(-2, 0): W
}

var width = 30
var height = 30

var erase_fraction = 0.2

var road_textures = [
	"cross_roads",
	"t_junction_road_down",
	"t_junction_road_left",
	"tr_curved_road",
	"t_junction_road_up",
	"horizontal_road",
	"br_curved_road",
	"right_dead_end_road",
	"t_junction_road_right",
	"tl_curved_road",
	"vertical_road",
	"top_dead_end_road",
	"bl_curved_road",
	"left_dead_end_road",
	"bottom_dead_end_road",
	"empty_cell"
]

var map_seed = 675343778

# Called when the node enters the scene tree for the first time.
func _ready():
	#while 1:
		if !map_seed:
			map_seed = OS.get_unix_time()
		seed(map_seed)
		randomize()
		while road_instances:
			road_instances[0].queue_free()
			road_instances.erase(road_instances[0])

		make_roads()
		erase_walls()
		Globals.roads = roads
		draw_roads()
		generate_vehicles()
		generate_people()

#		yield(get_tree().create_timer(1), "timeout")

func check_neighbors(cell, unvisited):
	# returns an array of cell's unvisited neighbors
	var list = []
	for n in cell_walls.keys():
		if cell + n in unvisited:
			list.append(cell + n)
	return list

func make_roads():
	var unvisited = []  # array of unvisited tiles
	var stack = []
	roads = {}
	# fill the map with solid tiles
	for x in range(width):
		for y in range(height):
			roads[Vector2(x, y)] =  N|E|S|W
	for x in range(0, width, 2):
		for y in range(0, height, 2):
			unvisited.append(Vector2(x, y))
	var current = Vector2(0, 0)
	unvisited.erase(current)
	
	# execute recursive backtracker algorithm
	
	while unvisited:
		var neighbors = check_neighbors(current, unvisited)
		if neighbors.size() > 0:
			var next = neighbors[randi() % neighbors.size()]
			stack.append(current)
			# remove walls from *both* cells
			var dir = next - current

			var current_walls = roads[current] - cell_walls[dir]
			var next_walls = roads[next] - cell_walls[-dir]
			roads[current] = current_walls
			roads[next] =  next_walls
			# insert intermediate cell
			if dir.x != 0:
				roads[current + dir/2] = 5;
			else:
				roads[current + dir/2] = 10
			current = next
			unvisited.erase(current)
		elif stack:
			current = stack.pop_back()
		# yield(get_tree(), 'idle_frame')

func draw_roads():
	# Loops through the tiles and draws the correct road
	for road in roads:
		var tex = load("res://textures/" + road_textures[roads[road]] + ".png")

		if road_textures[roads[road]] == "empty_cell":
			# Randomly decides to draw one of 2 building types
			place_buildings(road)
		else:
			# Roads tiles are placed here and the correct texture
			var physical_road = $road1.duplicate();
			physical_road.translation = Vector3(-29+(road.x*2), 0.01, -29+(road.y*2))
			var mat = physical_road.get_surface_material(0).duplicate()
			mat.albedo_texture = tex
			physical_road.set_surface_material(0, mat)
			road_instances.append(physical_road)
			self.add_child(physical_road)
			physical_road.set_owner(self)
		#yield(get_tree().create_timer(0.001), "timeout")

func erase_walls():
	# randomly remove a number of the map's walls
	for i in range(int(width * height * erase_fraction)):
		var x = int(rand_range(2, width/2 - 2)) * 2
		var y = int(rand_range(2, height/2 - 2)) * 2
		var cell = Vector2(x, y)
		#pick random neighbor
		var neighbor = cell_walls.keys()[randi() % cell_walls.size()]
		#if there's a wall between them, remove it
		if roads[cell] & cell_walls[neighbor]:
			var walls = roads[cell] - cell_walls[neighbor]
			var n_walls = roads[cell+neighbor] - cell_walls[-neighbor]
			roads[cell] = walls
			roads[cell+neighbor] = n_walls
			#insert intermediate cell
			if neighbor.x != 0:
				roads[cell+neighbor/2] = 5
			else:
				roads[cell+neighbor/2] = 10


func place_buildings(road):
	if randf() < 0.8:
		var y_pos = 1
		randomize()
		var rand = randf()
		var buildingNumber = 0
		
		# Chooses the buiding type that will be rendered
		if rand < 0.1:
			buildingNumber = 1
		elif rand < 0.2:
			buildingNumber = 4
		elif rand < 0.3:
			buildingNumber = 3
		else:
			buildingNumber = 2
		
		var building = load("res://models/Building" + str(buildingNumber) + "Model.tscn").instance()

		# Changes the building y position based on how tall it is
		if buildingNumber == 1:
			y_pos = 2
		elif buildingNumber == 3:
			y_pos = 0.5
		elif buildingNumber == 4:
			y_pos = 3
		
		building.translation = Vector3(-29+(road.x*2), y_pos, -29+(road.y*2))
		road_instances.append(building)
		self.add_child(building)
		building.set_owner(self)

func generate_people():
	for i in range(300):
		var person = load("res://models/Person.tscn").instance().duplicate()
		var child = person.get_child(0)
		child.translation.y = 0.1
		child.translation.x = -29
		child.translation.z = -29
		child.set_name("person_"+str(i))
		add_child(person)
		yield(get_tree().create_timer(1), "timeout")

func generate_vehicles():
	for i in range (300):
		var vehicle = load("res://models/" + ("Truck" if randi()%2 == 0 else "Car") + ".tscn")
		var vehicle_instance = vehicle.instance().duplicate()
		vehicle_instance.set_name("vehicle_"+str(i))
		var child = vehicle_instance.get_child(0)
		var model = child.get_child(0).get_child(0).get_child(0)
		var mat = model.get_surface_material(0).duplicate()
		randomize()
		mat.albedo_color = Color(randf(), randf(), randf(), randf())
		model.set_surface_material(0, mat)
		child.translation.y = 0.1
		child.translation.x = -29
		child.translation.z = -29
		add_child(vehicle_instance)
		yield(get_tree().create_timer(1), "timeout")
