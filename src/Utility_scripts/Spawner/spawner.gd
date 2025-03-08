extends Node2D

const ENEMY_SCENES = {
	"skeleton": preload("res://src/Enemies/Sceleton/skeleton_enemy.tscn"),
	"nightborne": preload("res://src/Enemies/Nightborne/nightborne.tscn"),
	"reaper": preload("res://src/Enemies/Zhnec/zhec.tscn")
}

const ENEMY_PROBABILITIES = [
	{"wave": 0, "probabilities": {"skeleton": 1.0}},
	{"wave": 5, "probabilities": {"skeleton": 0.7, "nightborne": 0.3}},
	{"wave": 10, "probabilities": {"skeleton": 0.5, "nightborne": 0.35, "reaper": 0.15}},
	{"wave": 15, "probabilities": {"skeleton": 0.4, "nightborne": 0.35, "reaper": 0.25}},
	{"wave": 20, "probabilities": {"skeleton": 0.4, "nightborne": 0.3, "reaper": 0.3}}
]

@onready var spawn_timer: Timer = $Area2D/SpawnTimer
@onready var spawn_area: CollisionShape2D = $Area2D/CollisionShape2D
@onready var label: Label = $"../UI/MarginContainer/VBoxContainer/HBoxContainer/Label"

@export var wave_delay: float = 5.0
@export var spawn_interval: float = 1.5
@export var max_enemies: int = 30

var current_wave: int = 0
var base_enemy_count: int = 4
var wave_multiplier: float = 1.2
var enemies_to_spawn: int = 0
var spawned_enemies: Array = []

func _ready():
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_SpawnTimer_timeout)
	start_wave()

func start_wave():
	current_wave += 1
	label.text = tr("WAWE") + ": " + str(current_wave)
	enemies_to_spawn = int(base_enemy_count * pow(wave_multiplier, current_wave))
	spawn_timer.start()
	get_tree().create_timer(wave_delay + spawn_interval * enemies_to_spawn).timeout.connect(start_wave, CONNECT_ONE_SHOT)

func _on_SpawnTimer_timeout():
	if enemies_to_spawn > 0:
		spawn_enemy()
		enemies_to_spawn -= 1
	else:
		spawn_timer.stop()

func spawn_enemy():
	if spawned_enemies.size() >= max_enemies:
		return

	var enemy_type = choose_enemy_type()
	var enemy_scene = get_enemy_scene(enemy_type)
	var enemy = enemy_scene.instantiate() as EnemyBase

	enemy.position = get_random_point_in_area()
	spawned_enemies.append(enemy)
	enemy.apply_wave_modifiers(current_wave)
	add_child(enemy)
	enemy.died.connect(_on_enemy_died.bind(enemy))

func get_enemy_scene(enemy_type: String) -> PackedScene:
	return ENEMY_SCENES.get(enemy_type, ENEMY_SCENES["skeleton"])

func choose_enemy_type() -> String:
	for entry in ENEMY_PROBABILITIES:
		if current_wave >= entry["wave"]:
			return weighted_random(entry["probabilities"])
	return "skeleton"

func weighted_random(probabilities: Dictionary) -> String:
	var roll = randf()
	var cumulative = 0.0
	for enemy in probabilities.keys():
		cumulative += probabilities[enemy]
		if roll < cumulative:
			return enemy
	return probabilities.keys()[0]

func get_random_point_in_area() -> Vector2:
	var shape = spawn_area.shape
	var area_position = spawn_area.global_position

	if shape is RectangleShape2D:
		var half_size = shape.size * 0.5
		return area_position + Vector2(randf_range(-half_size.x, half_size.x), randf_range(-half_size.y, half_size.y))
	
	if shape is CircleShape2D:
		var radius = shape.radius
		var angle = randf() * TAU
		var distance = sqrt(randf()) * radius
		return area_position + Vector2(cos(angle), sin(angle)) * distance
	
	return area_position

func _on_enemy_died(dead_enemy):
	spawned_enemies.erase(dead_enemy)
