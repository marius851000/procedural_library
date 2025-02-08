use std::fs::File;

use procedural_library_rust_native::{
    library_impl::AnnaBloomsburyMetadata, BookInfo, BookLibraryDatabase,
    GetBookRangeError,
};

pub fn main() {
    let file = File::open("/home/marius/procedural_library/test.jsonl.seekable").unwrap();
    let anna_metadata = AnnaBloomsburyMetadata::new(file).unwrap();

    println!("book_count: {}", anna_metadata.get_book_count());

    let callback = |r: Result<Vec<BookInfo>, GetBookRangeError>| {
        let r = r.unwrap();

        println!("{:?}", r);
    };

    anna_metadata
        .get_book_range(10, 20, Box::new(callback))
        .join()
        .unwrap();
}
