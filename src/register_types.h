/* Integration of vosk-api into godot
*/

#ifndef GDVOSK_REGISTER_TYPES_H
#define GDVOSK_REGISTER_TYPES_H

#include <godot_cpp/core/class_db.hpp>

using namespace godot;

void initialize_gdvosk_module(ModuleInitializationLevel p_level);
void uninitialize_gdvosk_module(ModuleInitializationLevel p_level);

#endif // GDVOSK_REGISTER_TYPES_H