use godot::prelude::*;

struct ProceduralLibraryExtension;

#[gdextension]
unsafe impl ExtensionLibrary for ProceduralLibraryExtension {}