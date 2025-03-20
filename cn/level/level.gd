extends Node2D

enum State{
	MORNING,
	DAY,
	EVENING,
	NIGHT
}

@onready var light = $Light/DirectionalLight2D
@onready var point_light = $Buildings/PointLight2D
@onready var day_text = $CanvasLayer/DayText
@onready var animPlayerText = $CanvasLayer/AnimationPlayer

@onready var player = $Player
const STATE_COUNT = 4
var state:State = State.MORNING 
var day = 1

func _ready() -> void:
	light.enabled = true
	day_text_fade()

func _process(_delta: float) -> void:
	pass
	
	
func morning_state():		
	var tween = get_tree().create_tween()
	tween.tween_property(light,"energy",0.2,3)
	tween.tween_property(point_light,"energy",0,1)

func evening_state():
	var tween = get_tree().create_tween()
	tween.tween_property(light,"energy",0.96,3)
	tween.tween_property(point_light,"energy",1.5,1)

func _on_timer_timeout() -> void:
	match state:
		State.MORNING:
			morning_state()
		State.DAY:
			pass
		State.EVENING:
			evening_state()
	
	if state < 3:
		state += 1 
	else:
		state = State.MORNING
		day += 1
		day_text_fade()
	

func day_text_fade():
	animPlayerText.play("day_text_fade_in")
	await get_tree().create_timer(3).timeout
	animPlayerText.play("day_text_fade_out")

	
