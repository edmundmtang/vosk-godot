/* Integration of vosk-api into godot
*/

#include "vosk_speech_recognizer.h"

#include <godot_cpp/core/class_db.hpp>

#ifndef CLAMP
#define CLAMP(m_a, m_min, m_max) (((m_a) < (m_min)) ? (m_min) : (((m_a) > (m_max)) ? m_max : m_a))
#endif

using namespace godot;
// ===== VoskSpeechRecognizer ===== //
void VoskSpeechRecognizer::_bind_methods() {
	// Properties
	ClassDB::bind_method(D_METHOD("set_model_path"), &VoskSpeechRecognizer::set_model_path);
	ClassDB::bind_method(D_METHOD("get_model_path"), &VoskSpeechRecognizer::get_model_path);
	ClassDB::bind_method(D_METHOD("set_sample_rate"), &VoskSpeechRecognizer::set_sample_rate);
	ClassDB::bind_method(D_METHOD("get_sample_rate"), &VoskSpeechRecognizer::get_sample_rate);
	
	ClassDB::bind_method(D_METHOD("get_buffer_size"), &VoskSpeechRecognizer::get_buffer_size);
	
	// Options
	ClassDB::bind_method(D_METHOD("set_words_option"), &VoskSpeechRecognizer::set_words_option);
	ClassDB::bind_method(D_METHOD("set_phones_option"), &VoskSpeechRecognizer::set_phones_option);
	ClassDB::bind_method(D_METHOD("set_timings_option"), &VoskSpeechRecognizer::set_timings_option);
	
	// Methods
	ClassDB::bind_method(D_METHOD("initialize", "path", "sample_rate"), &VoskSpeechRecognizer::initialize);
	ClassDB::bind_method(D_METHOD("reset"), &VoskSpeechRecognizer::reset);
	ClassDB::bind_method(D_METHOD("accept_waveform", "audio_data"), &VoskSpeechRecognizer::accept_waveform);
	ClassDB::bind_method(D_METHOD("get_partial"), &VoskSpeechRecognizer::get_partial);
	ClassDB::bind_method(D_METHOD("get_phone_partial"), &VoskSpeechRecognizer::get_phone_partial);
	ClassDB::bind_method(D_METHOD("get_final"), &VoskSpeechRecognizer::get_final);
}

void VoskSpeechRecognizer::set_model_path(String path) {
	model_path = path;
}

String VoskSpeechRecognizer::get_model_path() {
	return model_path;
}

void VoskSpeechRecognizer::set_sample_rate(int rate) {
	sample_rate = rate;
}

int VoskSpeechRecognizer::get_sample_rate() {
	return sample_rate;
}

int VoskSpeechRecognizer::get_buffer_size() {
	return sizeof buf;
}

void VoskSpeechRecognizer::set_words_option(bool words) {
	vosk_recognizer_set_words(speech_recognizer, words);
}

void VoskSpeechRecognizer::set_phones_option(bool phones) {
	vosk_recognizer_set_phones(speech_recognizer, phones);
}

void VoskSpeechRecognizer::set_timings_option(bool timings) {
	vosk_recognizer_set_timings(speech_recognizer, timings);
}

void VoskSpeechRecognizer::initialize(String path, float rate) {
	set_model_path(path);
	language_model = vosk_model_new(path.utf8().get_data());
	set_sample_rate(rate);
	speech_recognizer = vosk_recognizer_new(language_model, rate);
}

void VoskSpeechRecognizer::reset() {
	vosk_recognizer_reset(speech_recognizer);
}

int VoskSpeechRecognizer::accept_waveform(PackedByteArray data) {
	int len = data.size();
	memcpy(buf, data.ptr(), len);
	return vosk_recognizer_accept_waveform(speech_recognizer, buf, len);
}

String VoskSpeechRecognizer::get_partial() {
	return String(vosk_recognizer_partial_result(speech_recognizer));
}

String VoskSpeechRecognizer::get_phone_partial() {
	return String(vosk_recognizer_partial_phone_result(speech_recognizer));
}

String VoskSpeechRecognizer::get_final() {
	return String(vosk_recognizer_final_result(speech_recognizer));
}


// ===== AudioEffectCaptureExtend ===== //

void AudioEffectCaptureExtend::_bind_methods() {
	// Methods
	ClassDB::bind_method(D_METHOD("get_buffer_uint16", "frames"), &AudioEffectCaptureExtend::get_buffer_uint16);
}

inline unsigned int AudioEffectCaptureExtend::encode_uint16(uint16_t p_uint, uint8_t *p_arr) {
	for (int i = 0; i < 2; i++) {
		*p_arr = p_uint & 0xFF;
		p_arr++;
		p_uint >>= 8;
	}

	return sizeof(uint16_t);
}

PackedByteArray AudioEffectCaptureExtend::get_buffer_uint16(int p_frames) {
	PackedVector2Array vdata = get_buffer(p_frames);
	PackedByteArray data;
	data.resize(p_frames * 2);
	
	uint8_t *w = data.ptrw();
	for (int i = 0 ; i < p_frames ; i++) {
		int16_t u = CLAMP((vdata[i].x + vdata[i].y)*16384, -32768, 32767);
		encode_uint16(u, &w[i * 2]);
	}
	return data;
}

// ===== AudioEffectCustom ===== //
/*
void AudioEffectCustomInstance::_bind_methods() {

}


void AudioEffectCustom::_bind_methods() {

}

Ref<AudioEffectInstance> AudioEffectCustom::instantiate() {
	Ref<AudioEffectInstance> ins;
	ins.instantiate();
	ins->base = Ref<AudioEffectCustom>(this);
	
	
	return ins;
}
*/
