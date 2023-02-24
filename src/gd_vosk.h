#ifndef GDVOSK_H
#define GDVOSK_H

#include <Godot.hpp>
#include <Resource.hpp>
#include "vosk_api.h"

#include <stdio.h>

namespace godot {

class GDVosk : public Resource {
	GODOT_CLASS(GDVosk, Resource)

private:
	String model_path;
	float sample_rate;
	
	VoskModel * language_model;
	VoskRecognizer * voice_recognizer;
	
	char buf[4096];
	int nread;
	
public:
	static void _register_methods();
	void _init();
	GDVosk(); 
	~GDVosk();
	
	void initialize(String path, float rate);
	String get_path();
	
	int accept_waveform(PoolByteArray data);
	const char* get_partial();
	const char* get_final();
	const int buffer_size();
	
	void set_result_options(String result_opts);
	void set_verbose(bool verbose);
};

}

#endif	
	