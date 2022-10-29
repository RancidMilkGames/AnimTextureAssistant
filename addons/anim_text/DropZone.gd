## Plugin for assisting with Animated Texture work
##
## Improves the workflow for creating animated textures

@tool
extends Panel

## LineEdit node that determines the file's name
@onready var file_name: LineEdit = get_node("../FileNameLineEdit")
## LineEdit node that determines the file's path
@onready var des_path: LineEdit = get_node("../FileDestCont/LineEdit2")
## Playback speed of animation. Default is 1x
@onready var speed_num: SpinBox = get_node("../HBoxContainer/SpinBox")
## Delay duration between each frame. Default is 1 second
@onready var delay_num: SpinBox = get_node("../HBoxContainer2/SpinBox")
## ItemList node that will display the image paths to turn into an animated texture
@onready var img_list: ItemList = get_node("./ItemList")
## Label instructing the user where to drop files
@onready var instruct: Label = get_node("./Label")

## Array that stores the files/images that will be made into an animated texture
var file_paths = []
## Currently not in use. This might be implemented in the future to save preferences
var config = ConfigFile.new()
## Currently not in use. Might be paired with [member config] to save preferences in the future
var settings

func _ready():
	# Double check visibilities are correct
	img_list.visible = false
	instruct.visible = true
	
## Might include saving settings in future update
#	settings = config.load("res://addons/anim_text/settings.cfg")
#
#	if settings == OK:
#		for setting_sec in config.get_sections():
#			if setting_sec == "paths":
#				des_path.text = config.get_value(setting_sec, "anim_destination")
#	else:
#		config.set_value("paths", "anim_destination", "res://")


func _can_drop_data(at_position, data):
	var paths = data["files"]
	if paths[0].ends_with(".png") or paths[0].ends_with(".svg"):
		return true



func _drop_data(at_position, data):
	file_paths = data["files"]
	if file_paths.size() > 0:
		img_list.visible = true
		instruct.visible = false
		for path in file_paths:
			img_list.add_item(path)
	else:
		img_list.visible = false
		instruct.visible = true
		file_paths = []
	
	
func make_text():
	var new_text = AnimatedTexture.new()
	new_text.frames = file_paths.size()
	var c = 0
	for path in file_paths:
		if path.ends_with(".png") or path.ends_with(".svg"):
			new_text.set_frame_texture(c, load(path))
			new_text.set_frame_duration(c, delay_num.value)
			c += 1
	new_text.speed_scale = speed_num.value
	
	if file_name.text.is_empty():
		file_name.text = file_paths[0].split("/")[-1] #substr(6, 10)
	if not des_path.text.begins_with("res://"):
		des_path.text = "res://" + des_path.text
	if FileAccess.file_exists(des_path.text + file_name.text + ".tres"):
		increment_file_name()

			
	ResourceSaver.save(new_text, des_path.text + file_name.text + ".tres")
	img_list.visible = false
	instruct.visible = true
	file_paths = []


func _on_make_text_pressed():
	if file_paths.size() > 0:
		make_text()
		increment_file_name()
		


func _on_search_dest_butt_pressed():
	var dest = FileDialog.new()
	add_child(dest)
	dest.file_mode = FileDialog.FILE_MODE_OPEN_DIR
	dest.connect("dir_selected", set_dest, CONNECT_ONE_SHOT)
	dest.popup()
	
func set_dest(dest_str):
	des_path.text = dest_str
	
func increment_file_name():
	var last_char = file_name.text[-1].to_int()
	if is_nan(last_char) or last_char == 0:
		file_name.text += "1"
	else:
		last_char += 1
		file_name.text = file_name.text.trim_suffix(file_name.text[-1])
		file_name.text += str(last_char)
		if FileAccess.file_exists(des_path.text + file_name.text + ".tres"):
			increment_file_name()
