extends Node2D

@onready var terrain_layer = get_tree().root.find_child("TerrainLayer", true, false)
@onready var fog = get_tree().root.find_child("FogLayer", true, false)
@onready var player_nation = "England"
@onready var player_money = 100000

func _ready():
	MapLoader.load_map_data("res://data/resources/map_data.csv")
	print("✅ Loaded ", MapLoader.province_db.size(), " provinces")
	init_gameplay(player_nation)

func _unhandled_input(event):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		get_viewport().set_input_as_handled()
		var mouse_pos = get_global_mouse_position()
		var coords = terrain_layer.local_to_map(mouse_pos)
		
		if MapLoader.province_db.has(coords):
			var data = MapLoader.province_db[coords]
			print("=== ", data.name, " ===")
			
			if fog.has_fog(coords):
				print("This province is hidden in fog. Explore or send a spy to see")
				fog.reveal_province(coords)
				print("Fog cleared. Click again to see info.")
			else:
				print("Owner: ", data.owner)
				print("Claimant: ", data.claimant)
				print("Population: ", data.population)
				print("Development: ", data.development)

func init_gameplay(nation):
	print("=== INIT GAMEPLAY FOR ", nation, " ===")
	for coord in MapLoader.province_db:
		var data = MapLoader.province_db[coord]
		if data.owner == nation or data.claimant == nation:
			print("Revealing ", data.name)
			fog.reveal_province(coord)
func give_money():
	var player_provinces = []
	var player_claimed_provinces = []
	for coord in MapLoader.province_db:
		var data = MapLoader.province_db[coord]
		if data.owner == player_nation:
			player_provinces.append(data)
	for province in player_provinces:
		var money_to_give = int(round(province.development * (province.population / 1.3)))
		player_money += money_to_give
	for coord in MapLoader.province_db:
		var data = MapLoader.province_db[coord]
		if data.claimant == player_nation:
			player_claimed_provinces.append(data)
	for province in player_claimed_provinces:
		var money_to_give = int(round(province.development * (province.population / 1.3) / 5))
		player_money += money_to_give
