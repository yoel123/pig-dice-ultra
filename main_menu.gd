extends Control


var ye = load("res://yframework2d.gd").new()

onready var startbtn = $start
onready var creditsbtn = $credits
onready var backtbtn = $credits_screen.get_node("back")


func _process(delta):
	if startbtn.yclicked: get_tree().change_scene("res://game.tscn")
	if creditsbtn.clicked(): $credits_screen.visible = true
	if backtbtn.clicked(): $credits_screen.visible = false
	pass


