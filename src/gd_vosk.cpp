/* Integration of vosk-api into godot
*/

#include "gd_vosk.h"

#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void GDVosk::_bind_methods() {

	//register_property<GDVosk, String>("model_path", &GDVosk::model_path, "res://language_models/");
	//register_property<GDVosk, float>("sample_rate", &GDVosk::sample_rate, 44100);
	
	// Methods
	ClassDB::bind_method(D_METHOD("initialize", "path", "sample_rate"), &GDVosk::initialize);
	ClassDB::bind_method(D_METHOD("accept_waveform", "audio_data"), &GDVosk::accept_waveform);
	ClassDB::bind_method(D_METHOD("get_partial"), &GDVosk::get_partial);
	ClassDB::bind_method(D_METHOD("get_phone_partial"), &GDVosk::get_phone_partial);
	ClassDB::bind_method(D_METHOD("get_final"), &GDVosk::get_final);
	ClassDB::bind_method(D_METHOD("set_result_options", "result_option"), &GDVosk::set_result_options);
	ClassDB::bind_method(D_METHOD("set_verbose", "verbose"), &GDVosk::set_verbose);
	
	ClassDB::bind_method(D_METHOD("buffer_size"), &GDVosk::buffer_size);
}

void GDVosk::_init() {
}

GDVosk::GDVosk() {
}

GDVosk::~GDVosk() {
}

void GDVosk::initialize(String path, float rate) {
	model_path = path;
	language_model = vosk_model_new(path.utf8().get_data());
	sample_rate = rate;
	voice_recognizer = vosk_recognizer_new(language_model, rate);
}

String GDVosk::get_path() {
	return model_path;
}

int GDVosk::accept_waveform(PackedByteArray data) {
	int len = data.size();
	memcpy(buf, data.ptr(), len);
	return vosk_recognizer_accept_waveform(voice_recognizer, buf, len);
}

String GDVosk::get_partial() {
	return String(vosk_recognizer_partial_result(voice_recognizer));
}
String GDVosk::get_phone_partial() {
	return String(vosk_recognizer_partial_phone_result(voice_recognizer));
}

String GDVosk::get_final() {
	return String(vosk_recognizer_final_result(voice_recognizer));
}

int GDVosk::buffer_size() {
	return sizeof buf;
}

void GDVosk::set_result_options(String result_opts) {
	vosk_recognizer_set_result_options(voice_recognizer, result_opts.utf8().get_data());
}

void GDVosk::set_verbose(bool verbose) {
	vosk_recognizer_set_verbose(voice_recognizer, (int)verbose);
}