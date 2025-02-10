use std::fs::File;

use procedural_library_rust_native::{
    library_impl::AnnaBloomsburyMetadata, BookInfo, BookLibraryDatabase, GetBookRangeError,
};

pub fn main() {
    let file = File::open("/home/marius/procedural_library/test.jsonl.seekable").unwrap();
    let anna_metadata = AnnaBloomsburyMetadata::new(file).unwrap();

    println!("book length: {}", anna_metadata.get_library_length());

    let callback = |r: Result<Vec<(BookInfo, u64)>, GetBookRangeError>| {
        let r = r.unwrap();

        println!("{:?}", r);
    };

    anna_metadata
        .get_book_range_from_distance(0, 1000, false, Box::new(callback))
        .join()
        .unwrap();

    anna_metadata
        .get_book_range_from_distance(1, 100, false, Box::new(callback))
        .join()
        .unwrap();
}
