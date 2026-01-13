extends CanvasLayer

@onready var health_label = $Control/HealthLabel
@onready var mana_label = $Control/ManaLabel
@onready var gold_label = $Control/GoldLabel

func update_health(value: int, max_value: int):
	health_label.text = "HP: %d/%d" % [value, max_value]

func update_mana(value: int, max_value: int):
	mana_label.text = "Mana: %d/%d" % [value, max_value]

func update_gold(value: int):
	gold_label.text = "Gold: %d" % value
