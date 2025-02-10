use std::{
    fs::File,
    sync::{Arc, Mutex},
};

use godot::prelude::*;
use procedural_library_rust_native::{
    library_impl::AnnaBloomsburyMetadata, BookInfo, BookLibraryDatabase, GetBookRangeError,
};

struct ProceduralLibraryExtension;

#[gdextension]
unsafe impl ExtensionLibrary for ProceduralLibraryExtension {}

//TODO: convert to a ressource

#[derive(GodotClass)]
#[class(no_init)]
struct GodotBookInfo {
    book_info: BookInfo,
    distance: u64,
}

#[godot_api]
impl IRefCounted for GodotBookInfo {}

#[godot_api]
impl GodotBookInfo {
    #[func]
    pub fn get_title(&self) -> String {
        self.book_info.title.clone()
    }

    #[func]
    pub fn get_width(&self) -> u16 {
        self.book_info.width
    }

    #[func]
    pub fn get_distance(&self) -> u64 {
        self.distance
    }
}

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
    pub fn get_library_length(&self) -> u64 {
        self.library.get_library_length()
    }

    #[func]
    pub fn get_book_range_from_distance(
        &self,
        start_inclusive: u64,
        count: u64,
        always_return_one_book: bool,
    ) -> Array<Gd<GodotBookInfo>> {
        //TODO: make it work with background loading.

        let mutex = Arc::new(Mutex::new(None));
        let arc_clone = mutex.clone();
        self.library
            .get_book_range_from_distance(
                start_inclusive,
                count,
                always_return_one_book,
                Box::new(move |r: Result<Vec<(BookInfo, u64)>, GetBookRangeError>| {
                    //TODO: get rid of panic. For now, it should poison the lock (and crash. Which is good for debugging)
                    let mut value = arc_clone.lock().unwrap();

                    *value = Some(r.unwrap());
                }),
            )
            .join()
            .unwrap();

        //TODO: I should be able to get rid of the clone
        return mutex
            .lock()
            .unwrap()
            .clone()
            .unwrap()
            .into_iter()
            .map(|book_info| {
                Gd::from_init_fn(|_base| GodotBookInfo {
                    book_info: book_info.0,
                    distance: book_info.1,
                })
            })
            .collect();
    }
}
