extends Node2D

@onready var terrain_layer = get_tree().root.find_child("TerrainLayer", true, false)
@onready var fog_layer = get_tree().root.find_child("FogLayer", true, false)
var armies = {}
var selected_army = null

@onready var hex_neighbors = [
	Vector2i(1, 0),
	Vector2i(-1, 0),
	Vector2i(1, -1),
	Vector2i(0, -1),
	Vector2i(0, 1),
	Vector2i(-1, 1)
]

func _ready():
	add_army(Vector2i(4, 3), "England", "Scout", 1000)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var coords = terrain_layer.local_to_map(get_global_mouse_position())
		select_army(coords)
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT and selected_army != null:
		var destination = terrain_layer.local_to_map(get_global_mouse_position())
		
		if not is_known_place(destination):
			print("Not a valid province")
			return
		
		if is_water(destination):
			print("Cannot move to water")
			return
		
		# Find the path
		var path = find_path(selected_army.coords, destination)
		
		if path.size() == 0:
			print("No path found!")
			return
	
		# Store the path
		selected_army.path = path
		selected_army.path_index = 0
	
		print("Path found! ", path.size() - 1, " steps")
func add_army(coords: Vector2i, owner: String, type: String, size: int = 1000):
	var sprite = Sprite2D.new()
	
	var image = Image.create(32, 32, false, Image.FORMAT_RGBA8)
	image.fill(Color.TRANSPARENT)
	var center = 16
	var radius = 14
	for x in range(32):
		for y in range(32):
			var dx = x - center
			var dy = y - center
			if (dx * dx + dy * dy) < (radius * radius):
				image.set_pixel(x, y, get_color_for_owner(owner))
	
	sprite.texture = ImageTexture.create_from_image(image)
	sprite.position = terrain_layer.map_to_local(coords)
	add_child(sprite)
	
	armies[coords] = {
		"owner": owner,
		"manpower": size,
		"coords": coords,
		"sprite": sprite,
		"type": type,
	}

func get_color_for_owner(owner: String) -> Color:
	match owner:
		"England": return Color.RED
		"Scotland": return Color.BLUE
		"Ireland": return Color.GREEN
		_: return Color.WHITE

func select_army(coords: Vector2i):
	if armies.has(coords):
		# Deselect previous
		if selected_army != null:
			unhighlight_army(selected_army)
		
		selected_army = armies[coords]
		highlight_army(selected_army)
		print("Selected army at ", coords)
	else:
		if selected_army != null:
			unhighlight_army(selected_army)
			selected_army = null
			print("Deselected army")

func highlight_army(army_data):
	var sprite = army_data.sprite
	sprite.modulate = Color.YELLOW
	sprite.scale = Vector2(1.5, 1.5)

func unhighlight_army(army_data):
	var sprite = army_data.sprite
	sprite.modulate = get_color_for_owner(army_data.owner)
	sprite.scale = Vector2(1, 1)
	
func is_land(coords: Vector2i) -> bool:
	return MapLoader.province_db.has(coords)

func is_water(coords: Vector2i) -> bool:
	return not is_land(coords)
	
func is_known_place(coords: Vector2i) -> bool:
	return MapLoader.province_db.has(coords)

func get_neighbors(coords: Vector2i) -> Array:
	var neighbors = []
	for offset in hex_neighbors:
		var neighbor = coords + offset
		# Check if it's a valid province
		if MapLoader.province_db.has(neighbor):
			# Check if it's passable (not water)
			if MapLoader.province_db[neighbor].terrain != "water":
				neighbors.append(neighbor)
	return neighbors
	
func find_path(start: Vector2i, end: Vector2i) -> Array:
	var queue = [start]
	var visited = {}
	var parent = {}
	visited[start] = true
	
	while queue.size() > 0:
		var current = queue.pop_front()
		
		if current == end:
			# Reconstruct path
			var path = []
			while current in parent:
				path.append(current)
				current = parent[current]
			path.append(start)
			path.reverse()
			return path
		
		for neighbor in get_neighbors(current):
			if not visited.has(neighbor):
				visited[neighbor] = true
				parent[neighbor] = current
				queue.append(neighbor)
	
	return []  # No path found
	
func move_army_along_path(army_data):
	if army_data.path.size() == 0:
		return  # No path to follow
	
	var current_index = army_data.path_index
	if current_index >= army_data.path.size():
		army_data.path = []  # Path complete
		return
	
	var target_coords = army_data.path[current_index]
	
	# Move the army one step
	var old_coords = army_data.coords
	army_data.coords = target_coords
	army_data.sprite.position = terrain_layer.map_to_local(target_coords)
	armies[target_coords] = army_data
	armies.erase(old_coords)
	
	army_data.path_index += 1
	print("Army moved to step ", army_data.path_index, " of ", army_data.path.size())
