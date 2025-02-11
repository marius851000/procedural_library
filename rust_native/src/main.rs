use std::fs::File;

use procedural_library_rust_native::{BookInfo, BookLibraryDatabase, GetBookRangeError};

pub fn main() {
    /*let file = File::open("/home/marius/procedural_library/test.jsonl.seekable").unwrap();
    let metadata = procedural_library_rust_native::library_impl::AnnaBloomsburyMetadata::new(file).unwrap();*/
    let mut file = File::open("/home/marius/procedural_library/pg_catalog.csv").unwrap();
    let metadata =
        procedural_library_rust_native::library_impl::ProjectGutenbergCsvCatalog::new(&mut file)
            .unwrap();

    println!("book length: {}", metadata.get_library_length());

    let callback = |r: Result<Vec<(BookInfo, u64)>, GetBookRangeError>| {
        let r = r.unwrap();

        println!("{:?}", r);
    };

    metadata
        .get_book_range_from_distance(0, 1000, false, Box::new(callback))
        .join()
        .unwrap();
}
