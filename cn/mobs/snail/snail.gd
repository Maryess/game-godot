extends CharacterBody2D

@onready var animPlayer = $AnimationPlayer
@onready var collisionAttack = $AttackDirection/AtackRange/CollisionShape2D2
@onready var anim = $AnimatedSprite2D


var player
var direction 
var damage = 20
var health = 100

enum{
	IDLE,
	ATTACK,
	WALK,
	DAMAGE,
	DEATH
}

var state:int = 0:
	set(value):
		state = value
		match state:
			IDLE:
				idle_state()
			ATTACK:
				attack_state()
			DAMAGE:
				damage_state()
			DEATH:
				death_state()
	
			

func _ready() -> void:
	GlobalSignals.connect("player_position_update", Callable(self, "_on_player_position_update"))
	GlobalSignals.connect("player_attack_damage", Callable(self, "_on_player_attack"))
	

func _physics_process(delta: float) -> void:
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	if state == WALK:
		walk_state()
		
	move_and_slide()

func _on_player_position_update(player_pos):
	player = player_pos

func _on_atack_range_body_entered(_body: Node2D) -> void:
	state = ATTACK
	
func idle_state():
	animPlayer.play("Idle")
	await get_tree().create_timer(2.5).timeout
	$AttackDirection/AtackRange/CollisionShape2D2.disabled = false
	state = WALK

func attack_state():
	animPlayer.play("Attack")
	await animPlayer.animation_finished
	$AttackDirection/AtackRange/CollisionShape2D2.disabled = true
	state = IDLE

func walk_state():
	direction = (player - self.position).normalized()
	if direction.x < 0:
		anim.flip_h = false 
		$AttackDirection.rotation_degrees = -360
	else:
		anim.flip_h = true
		$AttackDirection.rotation_degrees = -180
	
func death_state():
	health = 0
	animPlayer.play("Death")
	await animPlayer.animation_finished
	queue_free()

func damage_state():
	velocity.x = 0
	animPlayer.play("Damage")
	await animPlayer.animation_finished
	state = IDLE

func _on_hit_damage_area_entered(_area: Area2D) -> void:
	print("hi ia am snaild")
	GlobalSignals.emit_signal("attack_damage", damage)

func _on_mob_health_minus_health() -> void:
	state = DEATH

func _on_mob_health_damage_received() -> void:
	state = IDLE
	state = DAMAGE
