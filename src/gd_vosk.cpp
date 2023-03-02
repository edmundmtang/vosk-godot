#include "gd_vosk.h"

using namespace godot;

void GDVosk::_register_methods() {

	register_property<GDVosk, String>("model_path", &GDVosk::model_path, "res://bin/");
	register_property<GDVosk, float>("sample_rate", &GDVosk::sample_rate, 44100);
	
	register_method("initialize", &GDVosk::initialize);
	register_method("accept_waveform", &GDVosk::accept_waveform);
	register_method("get_partial", &GDVosk::get_partial);
	register_method("get_phone_partial", &GDVosk::get_phone_partial);
	register_method("get_final", &GDVosk::get_final);
	register_method("buffer_size", &GDVosk::buffer_size);
	
	register_method("set_result_options", &GDVosk::set_result_options);
	register_method("set_verbose", &GDVosk::set_verbose);

}

void GDVosk::_init() {
}

GDVosk::GDVosk() {
}

GDVosk::~GDVosk() {
}

void GDVosk::initialize(String path, float rate) {
	model_path = path;
	language_model = vosk_model_new(path.alloc_c_string());
	sample_rate = rate;
	voice_recognizer = vosk_recognizer_new(language_model, rate);
}

String GDVosk::get_path() {
	return model_path;
}

int GDVosk::accept_waveform(PoolByteArray data) {
	int len = data.size();
	memcpy(buf, data.read().ptr(), len);
	return vosk_recognizer_accept_waveform(voice_recognizer, buf, len);
}

const char * GDVosk::get_partial() {
	return vosk_recognizer_partial_result(voice_recognizer);
}

const char * GDVosk::get_phone_partial() {
	return vosk_recognizer_partial_phone_result(voice_recognizer);
}

const char * GDVosk::get_final() {
	return vosk_recognizer_final_result(voice_recognizer);
}

const int GDVosk::buffer_size() {
	return sizeof buf;
}

void GDVosk::set_result_options(String result_opts) {
	vosk_recognizer_set_result_options(voice_recognizer, result_opts.alloc_c_string());
}

void GDVosk::set_verbose(bool verbose) {
	vosk_recognizer_set_verbose(voice_recognizer, (int)verbose);
}