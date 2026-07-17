extends TileMapLayer


func has_fog(coords: Vector2i) -> bool:
	return get_cell_source_id(coords) != -1

func reveal_province(coords: Vector2i):
	# Clear the visual fog tile
	set_cell(coords, -1)
	
	
	print("Revealed province at ", coords)
	if has_fog(coords):
		set_cell(coords, -1)
		print("Revealed: ", coords)
