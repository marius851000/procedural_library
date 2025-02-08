use std::thread::{self, JoinHandle};

use crate::{
    book_library_database::GetBookRangeError, BookInfo, BookLibraryDatabase,
};

pub struct VecBasedBookLibraryDatabase {
    pub books: Vec<BookInfo>,
}

impl VecBasedBookLibraryDatabase {
    pub fn new(books: Vec<BookInfo>) -> Self {
        Self { books }
    }
}

impl BookLibraryDatabase for VecBasedBookLibraryDatabase {
    fn get_book_count(&self) -> u64 {
        self.books.len() as u64
    }

    fn get_book_range(
        &self,
        start_inclusive: u64,
        count: u64,
        callback: Box<dyn FnOnce(Result<Vec<BookInfo>, GetBookRangeError>) + Send>,
    ) -> JoinHandle<()> {
        let result = if start_inclusive + count > self.books.len() as u64 {
            Err(GetBookRangeError::OutOfRange(start_inclusive, count))
        } else {
            Ok(self.books[start_inclusive as usize..(start_inclusive + count) as usize].to_vec())
        };
        thread::spawn(move || callback(result))
    }
}
