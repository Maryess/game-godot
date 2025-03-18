extends CharacterBody2D

signal health_changed(new_health)

enum{
	MOVE,
	ATTACK,
	BIG_ATTACK,
	SLIDE,
	SHIELD,
	JUMP,
	DAMAGE,
	DEATH
}
const JUMP_VELOCITY = -300.0
const SPEED = 100.0

@onready var anim = $AnimatedSprite2D
@onready var animPlayer = $AnimationPlayer

var max_health = 100
var health
var gold = 0
var state = MOVE
var run_speed_temp = 1
var sit = false
var player_poss

func _ready() -> void:
	GlobalSignals.connect("attack_damage", Callable(self,"_on_damage_attack"))
	health = max_health

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
	
	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		anim.play("Jump")
	
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
			sit = false
			if run_speed_temp == 1:
				anim.play("Move")
			else:
				anim.play("Run")
			
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		sit = true
		if velocity.y == 0:
			anim.play("Idle")

	if direction == -1:
		anim.flip_h = true
	elif direction == 1:
		anim.flip_h = false

	if Input.is_action_pressed("run"):
		run_speed_temp = 2
	else:
		run_speed_temp = 1
		 
	if Input.is_action_just_pressed("attack"):
		state = ATTACK
	
	if Input.is_action_just_pressed("big_attack"):
		state = BIG_ATTACK
	
	if Input.is_action_just_pressed("slide"):
		state = SLIDE
		
	if Input.is_action_pressed("shield"):
		state = SHIELD
	


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
	if sit == true:
		anim.play("Sit")
	else:
		anim.play("Slide")
	await anim.animation_finished
	state = MOVE

func shield_state():
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
	health -= damage_attack
	if health <= 0:
		health = 0
		state = DEATH
	else:
		state = DAMAGE
		
	emit_signal("health_changed", health)
	print(health)
