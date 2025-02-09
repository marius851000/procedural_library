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
            current_distance += 10; // some separation
        }
        Self {
            books_by_start_distance,
        }
    }
}

impl BookLibraryDatabase for VecBasedBookLibraryDatabase {
    fn get_book_count(&self) -> u64 {
        self.books_by_start_distance.len() as u64
    }

    fn get_book_range_from_distance(
        &self,
        start_inclusive: u64,
        length: u64,
        always_return_one_book: bool,
        callback: Box<dyn FnOnce(Result<Vec<(BookInfo, u64)>, GetBookRangeError>) + Send>,
    ) -> JoinHandle<()> {
        let result = if always_return_one_book {
            self.books_by_start_distance
                .range(..=start_inclusive)
                .last()
                .map_or(Err(GetBookRangeError::NoBookRegistered), |x| {
                    Ok(vec![(x.1.clone(), *x.0)])
                })
        } else {
            if start_inclusive == 0 {
                let mut r: Vec<(BookInfo, u64)> = self
                    .books_by_start_distance
                    .range(0..=length)
                    .map(|x| (x.1.clone(), *x.0))
                    .collect();
                r.pop();
                Ok(r)
            } else {
                let mut r: Vec<(BookInfo, u64)> = self
                    .books_by_start_distance
                    .range((start_inclusive - 1)..=(start_inclusive + length))
                    .skip(1)
                    .map(|x| (x.1.clone(), *x.0))
                    .collect();
                r.pop();
                Ok(r)
            }
        };

        thread::spawn(move || callback(result))
    }
}
