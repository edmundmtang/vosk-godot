/* Integration of vosk-api into godot
*/

#ifndef VOSK_SPEECH_RECOGNIZER_REGISTER_TYPES_H
#define VOSK_SPEECH_RECOGNIZER_REGISTER_TYPES_H

#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void initialize_vosk_speech_recognizer_module(ModuleInitializationLevel p_level);
void uninitialize_vosk_speech_recognizer_module(ModuleInitializationLevel p_level);

#endif // VOSK_SPEECH_RECOGNIZER_REGISTER_TYPES_H