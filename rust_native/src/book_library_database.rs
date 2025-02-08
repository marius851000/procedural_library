use std::thread::JoinHandle;

use thiserror::Error;

use crate::BookInfo;

#[derive(Error, Debug)]
pub enum GetBookRangeError {
    #[error("Out of range, start_inclusive: {0}, count: {1}")]
    OutOfRange(u64, u64),
}

pub trait GetBookRangeCallback: FnOnce(Result<Vec<BookInfo>, GetBookRangeError>) {}

pub trait BookLibraryDatabase {
    fn get_book_count(&self) -> u64;

    /**
     * Note: callback will always be run in a separate thread
     */
    fn get_book_range(
        &self,
        start_inclusive: u64,
        count: u64,
        callback: Box<dyn FnOnce(Result<Vec<BookInfo>, GetBookRangeError>) + Send>,
    ) -> JoinHandle<()>;
}
