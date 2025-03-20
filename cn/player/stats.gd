extends CanvasLayer

signal no_stamina()

signal health_change()

@onready var healthBar = $HealthBar
@onready var staminaBar = $Stamina
@onready var healthText = $"../Health/HealthText"
@onready var animHealth = $"../Health/AnimationHealth"



var max_health = 100
var stamina_cost = 0
var attack_stamina = 10
var block_stamina = 0.7
var slide_stamina = 20
var run_stamina = 0.4
var old_health = max_health

var stamina = 50:
	set(value):
		stamina = value
		if stamina < 1:
			emit_signal("no_stamina")

var health:
	set(value):
		health = clamp(value, 0 ,max_health)
		healthBar.value = health
		var difference = health - old_health
		old_health = health
		healthText.text = str(difference)
		if difference < 0:
			animHealth.play("damage")
		else:
			healthText.text = str(1)
			animHealth.play("health")
		

func _ready() -> void:
	health = max_health
	healthBar.max_value = health
	healthBar.value = health
	
func _process(delta: float) -> void:
	staminaBar.value = stamina
	if stamina < 100:
		stamina += 10 * delta

func stamina_consumption():
	stamina -= stamina_cost


func _on_regeneration_timeout() -> void:
	health += 1
