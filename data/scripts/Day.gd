extends Label

@onready var day = 0

func _ready():
	self.queue_redraw()

func _process(_delta: float) -> void:
	text = "turn:              " + str(day)

# In your turn system's end_turn() function
func end_turn():
	day += 1
	Game.give_money()
	
	# Move all armies along their paths
	var armies = Army.armies
	for coords in armies:
		print(armies[coords])
		if armies[coords].path.size() > 0:
			print("hello!")
			Army.move_army_along_path(armies[coords])
	
	print("Turn ", day, " ended")

func _on_button_pressed() -> void:
	print(day)
	end_turn()
