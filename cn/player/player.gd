extends CharacterBody2D

enum{
	MOVE,
	ATTACK,
	BIG_ATTACK,
	SLIDE,
	SHIELD,
	JUMP,
	DAMAGE,
	DEATH,
}
const JUMP_VELOCITY = -300.0
const SPEED = 100.0

@onready var anim = $AnimatedSprite2D
@onready var animPlayer = $AnimationPlayer
@onready var stats = $stats
@onready var healthText = $Health/HealthText
@onready var animHealth = $Health/AnimationHealth

var gold = 0
var state = MOVE
var run_speed_temp = 1
var player_poss
var damage = 10
var block_player = false

func _ready() -> void:
	GlobalSignals.connect("attack_damage", Callable(self,"_on_damage_attack"))


func _physics_process(delta: float) -> void:
	match state:
		MOVE:
			move_state()
		ATTACK:
			attack_state()
		BIG_ATTACK:
			big_attack_state()
		SLIDE:
			slide_state()
		SHIELD:
			shield_state()
		DAMAGE:
			damage_state()
		DEATH:
			death_state()

	if not is_on_floor():
		velocity += get_gravity() * delta
	
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
		#anim.play("Jump")

	if velocity.y > 0:
		anim.play("Fall")
	
	move_and_slide()
	
	player_poss = self.position
	GlobalSignals.emit_signal("player_position_update", player_poss)

func move_state():
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	
	if direction:
		velocity.x = direction * SPEED * run_speed_temp
		if velocity.y == 0:
			if run_speed_temp == 1:
				anim.play("Move")
			else:
				anim.play("Run")
					
				

			
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		if velocity.y == 0:
			anim.play("Idle")

	if direction == -1:
		anim.flip_h = true
		$AttackDirection.rotation_degrees = 180
	elif direction == 1:
		anim.flip_h = false
		$AttackDirection.rotation_degrees = 0

	if Input.is_action_pressed("run") and not block_player:
		run_speed_temp = 2
		stats.stamina -= stats.run_stamina
	else:
		run_speed_temp = 1
		 
	if Input.is_action_just_pressed("attack"):
		if block_player == false:
			stats.stamina_cost = stats.attack_stamina
			if stats.stamina > stats.stamina_cost:
				state = ATTACK
	
	if Input.is_action_just_pressed("big_attack"):
		state = BIG_ATTACK
	
	if Input.is_action_just_pressed("slide"):
		if block_player == false:
			stats.stamina_cost = stats.attack_stamina
			if stats.stamina > stats.stamina_cost:
				if run_speed_temp == 1:
					anim.play("Sit")
				else:
					state = SLIDE
	
	if Input.is_action_pressed("shield"):
		if stats.stamina > 1:
			state = SHIELD
	

func run_state():
	anim.play("Run")
	

func attack_state():
	velocity.x = 0
	animPlayer.play("Attack")
	await animPlayer.animation_finished
	state = MOVE

func big_attack_state():
	velocity.x = 0
	anim.play("Big_attack")
	await anim.animation_finished
	state = MOVE
	
func slide_state():
	animPlayer.play("Slide")
	await anim.animation_finished
	state = MOVE

func shield_state():
	stats.stamina -= stats.block_stamina
	velocity.x = 0
	anim.play("Shield")
	if  Input.is_action_just_released("shield"):
		state = MOVE

func death_state():
	velocity.x= 0
	anim.play("Death")
	await anim.animation_finished
	queue_free()
	await get_tree().create_timer(2).timeout
		
	
func damage_state():
	velocity.x = 0
	anim.play("Damage")
	await anim.animation_finished
	state = MOVE
	


func _on_damage_attack(damage_attack):
	if state == SHIELD:
		damage_attack /= 2
	elif state == SLIDE:
		damage_attack = 0
	else:
		state = DAMAGE
	stats.health -= damage_attack
	if stats.health <= 0:
		stats.health = 0
		state = DEATH
	else:
		state = DAMAGE

func _on_hit_damage_area_entered(area: Area2D) -> void:
	print("hi")
	GlobalSignals.emit_signal("player_attack_damage", damage)


func _on_stats_no_stamina() -> void:
	block_player = true
	await  get_tree().create_timer(2).timeout
	block_player = false
