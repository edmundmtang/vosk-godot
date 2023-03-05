/* Integration of vosk-api into godot
*/

#ifndef VOSK_SPEECH_RECOGNIZER_H
#define VOSK_SPEECH_RECOGNIZER_H

#include <godot_cpp/classes/node.hpp>
#include <godot_cpp/classes/audio_effect_capture.hpp>
#include <godot_cpp/core/binder_common.hpp>

#include "vosk_api.h"

using namespace godot;

class VoskSpeechRecognizer : public Node {
	GDCLASS(VoskSpeechRecognizer, Node);

private:
	String model_path;
	float sample_rate;
	
	VoskModel * language_model;
	VoskRecognizer * speech_recognizer;
	
	char buf[8192];
	int nread;

public:
	static void _bind_methods();

	void set_model_path(String path);
	String get_model_path();
	void set_sample_rate(int rate);
	int get_sample_rate();
	int get_buffer_size();
	
	void set_words_option(bool words);
	void set_phones_option(bool phones);
	void set_timings_option(bool timings);
	
	void initialize(String path, float rate);
	
	int accept_waveform(PackedByteArray data);
	String get_partial();
	String get_phone_partial();
	String get_final();
	
};

class AudioEffectCaptureExtend : public AudioEffectCapture {
	GDCLASS(AudioEffectCaptureExtend, AudioEffectCapture);
	
private:
	inline unsigned int encode_uint16(uint16_t p_uint, uint8_t *p_arr);
	
public:
	static void _bind_methods();
	
	PackedByteArray get_buffer_uint16(int p_frames);
	
};

#endif // VOSK_SPEECH_RECOGNIZER_H
	