/* Integration of vosk-api into godot
*/

#include "register_types.h"

#include <gdextension_interface.h>

#include <godot_cpp/core/class_db.hpp>
#include <godot_cpp/core/defs.hpp>
#include <godot_cpp/godot.hpp>

#include "vosk_speech_recognizer.h"
#include "tests.h"

using namespace godot;

void initialize_vosk_speech_recognizer_module(ModuleInitializationLevel p_level) {
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
		return;
	}
	
	ClassDB::register_class<VoskSpeechRecognizer>();
	ClassDB::register_class<AudioEffectCaptureExtend>();
	//ClassDB::register_class<AudioEffectCustom>();
	
}

void uninitialize_vosk_speech_recognizer_module(ModuleInitializationLevel p_level) {
	if (p_level != MODULE_INITIALIZATION_LEVEL_SCENE) {
		return;
	}
}

extern "C" {
// Initialization
GDExtensionBool GDE_EXPORT vosk_speech_recognizer_library_init(GDExtensionInterfaceGetProcAddress p_get_proc_address, GDExtensionClassLibraryPtr p_library, GDExtensionInitialization *r_initialization) {
	godot::GDExtensionBinding::InitObject init_obj(p_get_proc_address, p_library, r_initialization);

	init_obj.register_initializer(initialize_vosk_speech_recognizer_module);
	init_obj.register_terminator(uninitialize_vosk_speech_recognizer_module);
	init_obj.set_minimum_library_initialization_level(MODULE_INITIALIZATION_LEVEL_SCENE);

	return init_obj.init();
}
}