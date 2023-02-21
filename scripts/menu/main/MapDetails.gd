extends Control
class_name MapDetails

@export var maplist_path: NodePath
@onready var maplist:MapList = get_node(maplist_path)

@onready var map_buttons_list = $Maps/Buttons
@onready var origin_map_button = $Maps/Buttons/Button

var map_buttons = []

var mapset:Mapset
var map_index:int

func _ready():
	origin_map_button.visible = false
	$"../".visible = false
	maplist.connect("on_mapset_selected",Callable(self,"mapset_selected"))

func mapset_selected(selected_mapset:Mapset):
	$"../".visible = true
	mapset = selected_mapset
	update()
	map_selected(0)

func update():
	if mapset == null: return
	if mapset.cover == null:
		$CoverContainer/Cover.texture = preload("res://assets/images/branding/icon.png")
	else:
		$CoverContainer/Cover.texture = mapset.cover
	$Song.text = mapset.name
	$Creator.text = mapset.creator
	var online_id = mapset.online_id
	if online_id == null:
		online_id = "N/A"
	$Id.text = "id: %s" % online_id
	if !mapset.local:
		$Length.visible = false
		$Maps.visible = false
		return
	$Length.visible = true
	$Maps.visible = true
	var song_length:String
	if mapset.broken or mapset.audio == null:
		song_length = "N/A"
	else:
		var length = ceili(mapset.audio.get_length())
		var minutes = floori(length / 60)
		var minutes_t = str(minutes)
		var seconds = floori(length % 60)
		var seconds_t = str(seconds)
		if seconds < 10:
			seconds_t = "0" + seconds_t
		song_length = "%s:%s" % [minutes_t, seconds_t]
	$Length.text = song_length
	for button in map_buttons:
		button.queue_free()
	map_buttons = []
	var index = 0
	for map in mapset.maps:
		var button = origin_map_button.duplicate()
		button.visible = true
		button.text = map.name
		button.connect("pressed",Callable(self,"map_selected").bind(index))
		map_buttons_list.add_child(button)
		map_buttons.append(button)
		index += 1

func map_selected(selected_index:int=0):
	map_index = selected_index
	for button in map_buttons:
		button.button_pressed = false
		button.size_flags_stretch_ratio = 1
	map_buttons[map_index].button_pressed = true
	map_buttons[map_index].size_flags_stretch_ratio = 1.2
