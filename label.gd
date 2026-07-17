extends Label

func _process(delta: float) -> void:
	text = "money: " + str(Game.player_money)
