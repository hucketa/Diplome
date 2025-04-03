class_name  Spawner_logic
extends Node2D

signal wave_finished
signal wave_started



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
var shop_instance

func _ready():
	spawn_timer.wait_time = spawn_interval
	spawn_timer.timeout.connect(_on_SpawnTimer_timeout)

func start_wave():
	GameManager.__current_wave = current_wave
	for enemy in spawned_enemies:
		if is_instance_valid(enemy):
			enemy.queue_free()
	spawned_enemies.clear()
	current_wave += 1
	enemies_to_spawn = int(base_enemy_count * pow(wave_multiplier, current_wave))
	spawn_timer.start()
	emit_signal("wave_started")


func _on_SpawnTimer_timeout():
	if enemies_to_spawn > 0:
		spawn_enemy()
		enemies_to_spawn -= 1
	elif spawned_enemies.is_empty():
		spawn_timer.stop()

func spawn_enemy():
	if spawned_enemies.size() >= max_enemies:
		return

	var enemy_type = choose_enemy_type()
	var enemy_scene = get_enemy_scene(enemy_type)
	var enemy = enemy_scene.instantiate()

	enemy.position = get_random_point_in_area()
	spawned_enemies.append(enemy)
	get_tree().current_scene.add_child(enemy)

	if enemy.has_signal("died"):
		enemy.connect("died", Callable(self, "_on_enemy_died").bind(enemy))

	if enemy.has_method("apply_wave_modifiers"):
		enemy.apply_wave_modifiers(current_wave)

func _on_enemy_died(enemy):
	spawned_enemies.erase(enemy)

	if enemies_to_spawn == 0 and spawned_enemies.is_empty():
		wave_finished.emit()

func choose_enemy_type() -> String:
	var probabilities = ENEMY_PROBABILITIES[0]["probabilities"]
	for entry in ENEMY_PROBABILITIES:
		if current_wave >= entry["wave"]:
			probabilities = entry["probabilities"]
		else:
			break

	var rand = randf()
	var cumulative = 0.0
	for enemy_type in probabilities.keys():
		cumulative += probabilities[enemy_type]
		if rand <= cumulative:
			return enemy_type
	return "skeleton"

func get_enemy_scene(enemy_type: String) -> PackedScene:
	return ENEMY_SCENES.get(enemy_type, ENEMY_SCENES["skeleton"])

func get_random_point_in_area() -> Vector2:
	var rect = spawn_area.shape.get_rect()
	var x = randf_range(rect.position.x, rect.position.x + rect.size.x)
	var y = randf_range(rect.position.y, rect.position.y + rect.size.y)
	return Vector2(x, y) + spawn_area.global_position
	
func get_current_wave() -> int:
	return current_wave

func set_current_wave(a: int) -> void:
	current_wave = a
	start_wave()
