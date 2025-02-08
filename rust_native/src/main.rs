use std::fs::File;

use procedural_library_rust_native::{library_impl::AnnaBloomsburyMetadata, BookLibraryDatabase};

pub fn main() {
    let file = File::open("/home/marius/procedural_library/test.jsonl.seekable").unwrap();
    let anna_metadata = AnnaBloomsburyMetadata::new(file).unwrap();

    println!("book_count: {}", anna_metadata.get_book_count());
    
    
    //TODO: a good type of log, but given the specific of there, it’s not a problme.
    anna_metadata.get_book_range(10, 20, |r| {
        let r = r.unwrap();

        println!("{:?}", r);
    });

    
}
