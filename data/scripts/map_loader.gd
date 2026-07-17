extends Node

# This is your master database - accessible from anywhere
var province_db = {}

# This is the data structure for each province
class ProvinceData:
	var id: String
	var name: String
	var terrain: String
	var owner: String      # Changed from int to String
	var claimant: String   # Changed from int to String
	var religion: String
	var population: int
	var development: int
	var culture: String

func load_map_data(filepath: String):
	province_db.clear()
	
	var file = FileAccess.open(filepath, FileAccess.READ)
	if file == null:
		print("ERROR: Could not load ", filepath)
		return false
	
	var header = file.get_csv_line()
	print("Header: ", header)
	
	var line_count = 0
	while not file.eof_reached():
		var line = file.get_csv_line()
		if line.size() < 11:
			continue
		
		# q, r, id, name, terrain, owner, claimant, religion, population, development, culture
		var q = int(line[0])
		var r = int(line[1])
		var coords = Vector2i(q, r)
		
		var data = ProvinceData.new()
		data.id = line[2]
		data.name = line[3]
		data.terrain = line[4]
		data.owner = line[5]          # String (e.g., "England")
		data.claimant = line[6]       # String (e.g., "Scotland") or "none"
		data.religion = line[7]
		data.population = int(line[8])
		data.development = int(line[9])
		data.culture = line[10]
		
		province_db[coords] = data
		line_count += 1
	
	file.close()
	print("Loaded ", line_count, " provinces from CSV")
	return true

func get_province(coords: Vector2i):
	if province_db.has(coords):
		return province_db[coords]
	return null

func get_province_by_id(id: String):
	for coords in province_db:
		if province_db[coords].id == id:
			return province_db[coords]
	return null

func get_all_provinces():
	return province_db
