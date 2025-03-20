extends Node2D

signal minus_health()
signal damage_received()

@onready var healthBar = $HealthBar
@onready var damageText = $DamageText
@onready var animPlayer = $AnimationPlayer

var health = 100:
	set(value):
		health = value
		healthBar.value = health
		healthBar.visible = true
		if health <= 0:
			healthBar.visible = false

func _ready() -> void:
	GlobalSignals.connect("player_attack_damage", Callable(self, "_on_player_attack"))
	damageText.modulate = 0
	healthBar.max_value = health
	healthBar.visible = false

func _on_player_attack(player_damage):
	health -= player_damage
	damageText.text = str(player_damage)
	animPlayer.stop()
	animPlayer.play("damage_text")
	if health <= 0:
		emit_signal("minus_health")
	else:
		emit_signal("damage_received")
	print(health)
