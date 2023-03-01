class_name MouthTexture
extends Sprite

var upcoming_frames : Array = [[0,0]] # Elements are arrays of pairs of int
var timer : float = 0.0
var mirror_transitions = false
var animation_delay : float = 0.5
var target_delta: float = 0.016667
var phoneme_array : Array
var timings_array : Array

const PHONEME_GROUP : Dictionary = {
	0 : ["SIL"],
	1 : ["BB_", "PP_", "MM_"],
	2 : ["FF_", "VV_", "RR_"],
	3 : ["YY_", "IY_", "SS_", "SH_", "ZZ_", "ZH_"],
	4 : ["CH_", "TT_"],
	5 : ["DD_", "GG_", "KK_", "NN_", "NG_", "JH_", "HH_"],
	6 : ["TH_", "DH_", "LL_"],
	7 : ["EH_", "EY_", "IH_"],
	8 : ["AA_", "AE_", "AH_", "AO_", "AW_", "AY_"],
	9 : ["UH_", "ER_"],
	10 : ["OY_"],
	11 : ["WW_", "OW_"],
}

func _ready():
	pass

func reset_pointer():
	timer = 0 - animation_delay

func add_next_texture(phoneme_labels: Array, phoneme_timings: Array) -> void:
	# Queues the next texture in the array of upcoming frames
	phoneme_array = phoneme_labels
	timings_array = phoneme_timings
	var index_triple = get_label_index_triple()
	add_frame(
		analyze_for_frame(
			index_triple_to_state_triple(
				index_triple)))

func get_label_index_triple() -> Array:
	var result := []
	var reference_time := timer
	var j = 0
	for _i in range(3):
		if timer < 0:
			result.append(-1)
		else:
			while j < timings_array.size():
				if reference_time < timings_array[j]:
					result.append(j)
					break
				j += 1
			if j >= timings_array.size():
				result.append(-1)
				# To-Do: We're going to need to figure out how to reach into the next segment at this point
		reference_time += target_delta # target_delta might need to be true delta depending on how lag/time updates interact
	return result

func index_triple_to_state_triple(triple: Array) -> Array:
	var result = [0, 0, 0]
	for i in range(3):
		if triple[i] == -1:
			result[i] = 0
			continue
		var label = phoneme_array[triple[i]]
		label.erase(3,1)
		result[i] = phoneme_to_state(label)
	return result

func phoneme_to_state(phoneme_label: String) -> int:
	for key in PHONEME_GROUP.keys():
		if phoneme_label in PHONEME_GROUP[key]:
			return key
	return 0

func analyze_for_frame(triple: Array) -> Array:
	# Checks a sequence of three states and decides on what frame should correspond to the middle
	# state. Frames are represented using a pair of indices (row, col)
	if triple[0] == triple[1]: # We use transition frames only if we have repeats
		return [triple[1], triple[2]]
	else:
		return [triple[1], triple[1]]


func add_frame(frame_coords: Array):
	# Adds a frame to the queue of upcoming frames
	var new_frame := frame_coords
	if mirror_transitions:
		new_frame.sort()
	upcoming_frames.push_back(new_frame)

func update_frame(delta) -> void:
	timer += delta
	var next_frame_coords : Array = upcoming_frames.pop_front()
	self.frame_coords = Vector2(next_frame_coords[0], next_frame_coords[1])
