use std::{fs::File, sync::{Arc, Mutex}};

use godot::prelude::*;
use procedural_library_rust_native::{library_impl::AnnaBloomsburyMetadata, BookInfo, BookLibraryDatabase, GetBookRangeError};

struct ProceduralLibraryExtension;

#[gdextension]
unsafe impl ExtensionLibrary for ProceduralLibraryExtension {}

#[derive(GodotClass)]
#[class(base = Node)]
struct GodotProceduralLibraryData {
    library: Box<dyn BookLibraryDatabase>,
}

//TODO: A nicer way to load libraries (with error handling and background loading)
#[godot_api]
impl INode for GodotProceduralLibraryData {
    fn init(_base: Base<Node>) -> Self {
        let file = File::open("/home/marius/procedural_library/test.jsonl.seekable").unwrap();
        let anna_metadata = AnnaBloomsburyMetadata::new(file).unwrap();

        Self {
            library: Box::new(anna_metadata),
        }
    }
}

#[godot_api]
impl GodotProceduralLibraryData {
    #[func]
    pub fn get_book_count(&self) -> u64 {
        self.library.get_book_count()
    }

    #[func]
    pub fn get_book_title(&self, index: u64) -> String {
        //TODO: make it work with background loading. Also horrible naming.
        let result = Arc::new(Mutex::new(None));
        let arc_clone = result.clone();
        self.library.get_book_range(index, 1, Box::new(move |r: Result<Vec<BookInfo>, GetBookRangeError>| {
            //TODO: get rid of panic. For now, it should poison the lock.
            let mut value = arc_clone.lock().unwrap();

            *value = Some(r.unwrap()[0].title.clone());
        })).join().unwrap();

        return result.lock().unwrap().clone().unwrap();
    }

    //TODO: merge with get_book_title
    #[func]
    pub fn get_book_width(&self, index: u64) -> f32 {

        //TODO: make it work with background loading. Also horrible naming.
        let result = Arc::new(Mutex::new(None));
        let arc_clone = result.clone();
        self.library.get_book_range(index, 1, Box::new(move |r: Result<Vec<BookInfo>, GetBookRangeError>| {
            //TODO: get rid of panic. For now, it should poison the lock.
            let mut value = arc_clone.lock().unwrap();

            *value = Some(r.unwrap()[0].width.clone());
        })).join().unwrap();

        return result.lock().unwrap().clone().unwrap();
    }
}