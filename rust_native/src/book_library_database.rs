use thiserror::Error;

use crate::BookInfo;

#[derive(Error, Debug)]
pub enum GetBookRangeError {
    #[error("Out of range, start_inclusive: {0}, count: {1}")]
    OutOfRange(u64, u64),
}

pub trait BookLibraryDatabase {
    fn get_book_count(&self) -> u64;

    fn get_book_range<F: FnOnce(Result<Vec<BookInfo>, GetBookRangeError>)>(&self, start_inclusive: u64, count: u64, callback: F) -> ();
}