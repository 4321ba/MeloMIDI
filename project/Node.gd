extends Node

func _ready():
	var test = load("res://bin/spectrum_analyzer.gdns").new()
	var ret = test.analyze_spectrum("abcdefgh")
	print(ret)
