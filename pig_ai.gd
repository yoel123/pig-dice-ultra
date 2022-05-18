extends Node

#pass the object the games dice scenes
var dice
var dice2
var dice3

#needs game object
var game

#ai type name
var ai_type = "stupid"

var ai_types = ["stupid","smart","random"]

var roll_times = 0 #how many times rolled this turn

var wait_timer = 2
var wait_timer_count = 0


func _ready():
	pass # Replace with function body.

func init():
	pass
	
	
func do_roll(delta):
	#dice roll need to be done (not rolling) for ai to take action
	if not all_dice_done():return
	
	#wait timer
	wait_timer_count += delta 
	
	if wait_timer_count < wait_timer and all_dice_done(): return
	wait_timer_count = 0
	
	if ai_type =="stupid":
		#if got a score of 12 
		if game.current_score >= 12: 
			game.ai_pass_turn = true
			return
		dice.roll()
		dice2.roll()
		dice3.roll()
		
	
	pass
	
func all_dice_done():
	if  dice.done_roll and  dice2.done_roll and  dice3.done_roll:
		return true
