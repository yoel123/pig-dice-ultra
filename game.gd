extends Node2D

var other_player_item = preload("res://other_player.tscn")
var pig_ai = preload("res://pig_ai.gd")
#sounds
var asp = AudioStreamPlayer.new()
var pig_sound1 = preload("res://sounds/1.wav")
var pig_sound2 = preload("res://sounds/2.wav")
var pig_sound3 = preload("res://sounds/3.wav")

"""
if !asp.is_playing():
		asp.stream = pig_sound
		asp.play()
	  var sound_has_played = false
	  if !sound_has_played:
			sound_has_played = true
			$Audio.play()
"""
var rng = RandomNumberGenerator.new()
var pai

var current_player = 0
var winner
var players = []
var other_player_items = []
var current_screen = "pre_game"
var current_score = 0
var turn_done = false
var turn_lost = false

#start screen
onready var pre_game_screen = $pre_game_screen
#starr game btn
onready var start_game = $pre_game_screen.get_node("start_game")
#pass turn screen (between screens)
onready var pass_turn_screen = $pass_turn_screen
onready var win_screen = $win_screen

#btns
onready var roll1 = $roll1
onready var roll2 = $roll2
onready var roll3 = $roll3
onready var pass_turn = $pass_turn
onready var start_turn = $pass_turn_screen.get_node("start_turn")
onready var back_to_start = $win_screen.get_node("back_to_start")

#dice
onready var dice = $dice
onready var dice2 = $dice2
onready var dice3 = $dice3

#txt labels
onready var current_player_txt = $current_player_txt
onready var player_score = $player_score
onready var current_score_txt = $current_score_txt
onready var next_player_label = $pass_turn_screen.get_node("next_player_label")
onready var winner_txt = $win_screen.get_node("winner_txt")
onready var player_num_input = $pre_game_screen.get_node("player_num_input")
onready var ai_players_in = $pre_game_screen.get_node("ai_players_in")

onready var player_img = $player.get_node("Sprite")




var other_player_pos = {"x":166,"y":48}
var other_player_top_margin = 50;
var other_player_top = 25;

var wait_end_turn_timer = 0.3
var wait_end_turn_timer_count = 0

var ai_pass_turn

func _ready():
	print(start_turn)
	var p1 = make_player()
	p1.name = "p1"
	var p2 = make_player()
	p2.name = "p2"
	
	players.append(p1)
	players.append(p2)
	
	#init pig ai
	pai = pig_ai.new()
	pai.dice = dice
	pai.dice2 = dice2
	pai.dice3 = dice3
	pai.game = self
	add_child(asp)#add sound manger
	pass


func _process(delta):

	if current_screen=="pass_turn":
		pass_turn_screen.visible = true
		if start_turn.clicked():
			pass_turn_screen.visible = false
			current_screen="game"
	if current_screen=="win_screen":
		win_screen.visible=true
		if back_to_start.clicked():
			win_screen.visible=false
			get_tree().change_scene("res://main_menu.tscn")
		pass
	if current_screen=="game":
		pre_game_screen.visible = false
		game_update(delta)
		pass	
	#pre game setup
	if current_screen=="pre_game":
		pre_game_screen.visible = true
		if start_game.clicked():
			new_game()
			current_screen="game"
		pass
	#end pre game
	
	if current_screen=="end_game":
		pass
	
	pass


func game_update(delta):
	
	#update ui data
	current_score_txt.text = "turn score: "+str(current_score)
	current_player_txt.text = "current player: "+players[current_player].name
	player_score.text = "score: "+str(players[current_player].score)
	player_img.frame = players[current_player].sprite
	
	#update other player items
	update_other_player_items()
	
	#ai requester turn pass
	if ai_pass_turn:pass_turn(delta)
	
	#lost turn
	if turn_lost:
		current_score = 0
		#only thing you can do is pass the turn
		pass_turn(delta)
		return #exit func current player cant do anything
	
	#if current player is ai
	if players[current_player].is_ai:
		pai.ai_type = players[current_player].ai_type
		pai.do_roll(delta)
		pass
	else:
		#if current player is human
		if roll1.clicked():
			dice.roll()
			pass
		if roll2.clicked():
			dice.roll()
			dice2.roll()
			pass
		if roll3.clicked():
			dice.roll()
			dice2.roll()
			dice3.roll()
			pass
		pass_turn(delta)
	
	
	pass
#end game_update

func new_game():
	winner = null
	
	#number of humen and bot players
	var ai_players = int(ai_players_in.text)
	var human_players = int(player_num_input.text)
	players = [] #reset players
	#create humen players
	for h in human_players:
		var hp = make_player()
		hp.name = "player"+str(h+1)
		players.append(hp)
		pass
	#create ai players
	for ai in ai_players:
		var aip = make_player()
		aip.name = "ai_player"+str(ai+1)
		aip.is_ai = true
		players.append(aip)
		pass
  
	
	
	#create player side tooltip elements
	var other_player_item_instance
	#create other player items
	for p in players:
		other_player_item_instance = other_player_item.instance()
		other_player_item_instance.position.x = other_player_pos.x
		other_player_item_instance.position.y = other_player_pos.y+other_player_top
		other_player_top += other_player_top_margin;
		other_player_items.append(other_player_item_instance)
		other_player_item_instance.get_node("Sprite").frame = p.sprite
		call_deferred("add_child",other_player_item_instance)
		
		pass
	pass
#end game_update

func update_other_player_items():
	if other_player_items.size()<=0: return
	var c = 0
	for i in other_player_items:
		i.get_node("name").text = players[c].name
		i.get_node("score").text = str(players[c].score)
		c += 1
		pass
#end update_other_player_items

#player loss turn
func lose_turn():
	
	#play pig squeel
	rng.randomize()
	var rnd_sound=rng.randi_range(1,3)
	if !asp.is_playing():
		if rnd_sound ==1: asp.stream = pig_sound1
		if rnd_sound ==2: asp.stream = pig_sound2
		if rnd_sound ==3: asp.stream = pig_sound3
		asp.play()

	
	current_score = 0
	turn_lost = true
	pass
#end lose_turn

#player paces turn
func pass_turn(delta):
	
	#if player is not ai
	if !players[current_player].is_ai:
		#check if clicked pass turn and
		if !pass_turn.clicked():return
	#if ai wait
	if players[current_player].is_ai:
		wait_end_turn_timer_count +=delta
		if wait_end_turn_timer_count >= wait_end_turn_timer:
			wait_end_turn_timer_count = 0
		else:return #if timer not done exits
	
	#reset btns click flag
	roll1.clicked()
	roll2.clicked()
	roll3.clicked()
	
			
	ai_pass_turn = false
	turn_lost = false
	players[current_player].score += current_score
	
	#check win condition
	if players[current_player].score>=100:
		winner = players[current_player]
		current_screen="win_screen"
		winner_txt.text = "the winner is: "+winner.name+" score: "+str(winner.score)
		return
		pass
	#set player img	
	player_img.frame = players[current_player].sprite
	current_score = 0 #reset current score
	current_player +=1 #set next player
	#reached last player go to first
	if current_player>=players.size(): current_player=0
	#set next player label
	next_player_label.text = "next player is: "+ players[current_player].name
	

	#go to pass turn screen
	current_screen="pass_turn"
	pass


func make_player():
	rng.randomize()
	var rnd_sprite=rng.randi_range(0,4)
	return {
		"name":"",
		"score":0,
		"is_ai":false,
		"ai_type":"stupid",
		"sprite":rnd_sprite
	}
#end make_player



"""
plan:
	
	*loss turn condition v
	*pass turn v
	-update player score v
	-check win condition
	*win game condition (reach 100 first)
	*win game screen
	*show other player


"""


