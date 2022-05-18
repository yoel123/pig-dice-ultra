extends Node2D

onready var game = get_tree().get_current_scene()
onready var sprite = $Sprite

var dice_val = 1

#timers
var dice_anim_count = 0
var dice_anim_time = 0.04
var roll_time_count = 0
var roll_time_rimer = 0.8
var done_roll = true



func _ready():
	pass 


func _process(delta):
	
	roll_do(delta)
	
	pass

func animate_dice(delta):
	dice_anim_count = dice_anim_count + delta
	if dice_anim_count >= dice_anim_time:
		sprite.frame = randi() % 6
		dice_anim_count = 0
#end animate_dice

func roll():
	reset()
	dice_sound()
func reset():
	roll_time_count = 0
	dice_val =0
	done_roll = false
	
func roll_do(delta):
	#only roll when dice val is reset
	if dice_val !=0:return
	#inc roll timer
	roll_time_count = roll_time_count+delta
	#if roll timer not done animate dice
	if roll_time_count <=roll_time_rimer:
		animate_dice(delta)
	
	else:
		done_roll = true
		#once roll timer done set dice to rand val
		dice_val = sprite.frame+1 #same as the last sprite frame that showes the num
		game.current_score +=dice_val#add to current turn score
		#if dice val is 1 lose turn
		if dice_val == 1:
			game.lose_turn()
		#print(dice_val)
func roll_d6():
	return  randi() % 6
	
	
func dice_sound():
	pass
