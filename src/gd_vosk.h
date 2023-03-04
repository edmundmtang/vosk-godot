/* Integration of vosk-api into godot
*/

#ifndef GDVOSK_H
#define GDVOSK_H

#include <godot_cpp/classes/ref_counted.hpp>
#include <godot_cpp/core/binder_common.hpp>

#include "vosk_api.h"

//#include <stdio.h>

using namespace godot;

class GDVosk : public RefCounted {
	GDCLASS(GDVosk, RefCounted)

private:
	String model_path;
	float sample_rate;
	
	VoskModel * language_model;
	VoskRecognizer * voice_recognizer;
	
	char buf[8192];
	int nread;

public:
	static void _bind_methods();
	void _init();
	GDVosk(); 
	~GDVosk();
	
	void initialize(String path, float rate);
	String get_path();
	
	int accept_waveform(PackedByteArray data);
	String get_partial();
	String get_phone_partial();
	String get_final();
	int buffer_size();
	
	void set_result_options(String result_opts);
	void set_verbose(bool verbose);
};

#endif	// GDVOSK_H
	