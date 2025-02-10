use std::{
    collections::BTreeMap,
    thread::{self, JoinHandle},
};

use crate::{book_library_database::GetBookRangeError, BookInfo, BookLibraryDatabase};

pub struct VecBasedBookLibraryDatabase {
    pub books_by_start_distance: BTreeMap<u64, BookInfo>,
}

impl VecBasedBookLibraryDatabase {
    pub fn new(books_list: Vec<BookInfo>) -> Self {
        let mut books_by_start_distance = BTreeMap::new();
        let mut current_distance: u64 = 0;

        for book in books_list.into_iter() {
            let book_width = book.width;
            books_by_start_distance.insert(current_distance, book);
            current_distance += book_width as u64;
        }
        Self {
            books_by_start_distance,
        }
    }
}

impl BookLibraryDatabase for VecBasedBookLibraryDatabase {
    fn get_library_length(&self) -> u64 {
        if let Some((last_key, last_value)) = self.books_by_start_distance.last_key_value() {
            *last_key + (last_value.width as u64)
        } else {
            0
        }
    }

    fn get_book_range_from_distance(
        &self,
        start_inclusive: u64,
        length_exclusive: u64,
        always_return_one_book: bool,
        callback: Box<dyn FnOnce(Result<Vec<(BookInfo, u64)>, GetBookRangeError>) + Send>,
    ) -> JoinHandle<()> {
        let result = if always_return_one_book {
            if start_inclusive >= self.get_library_length() {
                Err(GetBookRangeError::OutOfRange)
            } else {
                self.books_by_start_distance
                    .range(..=start_inclusive)
                    .last()
                    .map_or(Err(GetBookRangeError::OutOfRange), |x| {
                        Ok(vec![(x.1.clone(), *x.0)])
                    })
            }
        } else {
            Ok(self
                .books_by_start_distance
                .range(start_inclusive..(start_inclusive + length_exclusive))
                .map(|x| (x.1.clone(), *x.0))
                .collect())
        };

        thread::spawn(move || callback(result))
    }
}
