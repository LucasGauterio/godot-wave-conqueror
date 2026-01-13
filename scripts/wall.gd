extends StaticBody2D
class_name KingdomWall

signal health_changed(current, max)
signal destroyed

@export var max_health: int = 100
var current_health: int

enum WallTier { WOOD, STONE, REINFORCED }
@export var tier: WallTier = WallTier.WOOD

@onready var health_bar = $HealthBar

func _ready():
	current_health = max_health
	if health_bar:
		health_bar.max_value = max_health
		health_bar.value = current_health
	add_to_group("wall")
	queue_redraw()

func _draw():
	var screen_width = get_viewport_rect().size.x
	var wall_height = 64.0
	var wall_rect = Rect2(-screen_width/2, -wall_height/2, screen_width, wall_height)
	
	match tier:
		WallTier.WOOD:
			draw_wood_fence(wall_rect)
		WallTier.STONE:
			draw_stone_wall(wall_rect)
		WallTier.REINFORCED:
			draw_reinforced_wall(wall_rect)

func draw_wood_fence(rect: Rect2):
	var wood_color = Color(0.5, 0.3, 0.1)
	var dark_wood = Color(0.35, 0.2, 0.05)
	
	# Draw background bar
	draw_rect(rect, wood_color)
	
	# Draw vertical posts
	var post_width = 12.0
	var spacing = 20.0
	var current_x = rect.position.x
	while current_x < rect.end.x:
		draw_rect(Rect2(current_x, rect.position.y - 10, post_width, rect.size.y + 20), wood_color)
		draw_rect(Rect2(current_x + 2, rect.position.y - 8, post_width - 4, rect.size.y + 16), Color(0.6, 0.4, 0.2)) # Highlight
		current_x += spacing
	
	# Draw horizontal rails
	draw_rect(Rect2(rect.position.x, rect.position.y + 10, rect.size.x, 8), dark_wood)
	draw_rect(Rect2(rect.position.x, rect.position.y + 45, rect.size.x, 8), dark_wood)

func draw_stone_wall(rect: Rect2):
	var stone_color = Color(0.5, 0.5, 0.5)
	var mortar_color = Color(0.3, 0.3, 0.3)
	
	draw_rect(rect, mortar_color)
	
	var brick_w = 40.0
	var brick_h = 20.0
	for y in range(0, 3):
		var offset = (y % 2) * (brick_w / 2)
		for x in range(int(rect.position.x / brick_w) - 1, int(rect.end.x / brick_w) + 1):
			var b_rect = Rect2(x * brick_w + offset, rect.position.y + y * brick_h, brick_w - 2, brick_h - 2)
			draw_rect(b_rect, stone_color)

func draw_reinforced_wall(rect: Rect2):
	draw_stone_wall(rect)
	# Add metal reinforcements
	var metal_color = Color(0.4, 0.4, 0.45)
	var silver_color = Color(0.7, 0.7, 0.7)
	
	var spacing = 100.0
	var current_x = rect.position.x + 50
	while current_x < rect.end.x:
		# Vertical brace
		draw_rect(Rect2(current_x - 5, rect.position.y, 10, rect.size.y), metal_color)
		# Rive/Bolts
		draw_circle(Vector2(current_x, rect.position.y + 10), 3, silver_color)
		draw_circle(Vector2(current_x, rect.position.y + 54), 3, silver_color)
		current_x += spacing

func take_damage(amount: int):
	current_health = max(0, current_health - amount)
	if health_bar:
		health_bar.value = current_health
	health_changed.emit(current_health, max_health)
	
	print("Wall hit! Health: ", current_health)
	
	if current_health <= 0:
		die()

func die():
	destroyed.emit()
	print("Wall destroyed!")
	queue_free()
