use std::thread::JoinHandle;

use thiserror::Error;

use crate::BookInfo;

#[derive(Error, Debug)]
pub enum GetBookRangeError {
    #[error("No book registered")]
    NoBookRegistered,
}

#[derive(Error, Debug)]
pub enum GetBookIdFromDistanceError {}

pub trait GetBookRangeCallback: FnOnce(Result<Vec<BookInfo>, GetBookRangeError>) {}

pub trait BookLibraryDatabase {
    fn get_book_count(&self) -> u64;

    /**
     * Note: callback will always be run in a separate thread
     * Distance is in centimeter
     *
     * Book occupy a range as in book_distance=..next_book_distance
     * if get_book_at_start is true, it return the single book that is at start_inclusive (not making use of length)
     * 
     * if get_book_at_start is false, then it return a list of book from:
     * first book: the next beggining of a book (so if it is on a book range but not the start position, it get the next book)
     * end book: the last book that occupy the range at start_inclusive + length_exclusive (if it is the beggining of a new book, it doesn’t take it)
     */
    fn get_book_range_from_distance(
        &self,
        start_inclusive: u64,
        length_exclusive: u64,
        get_book_at_start: bool,
        callback: Box<dyn FnOnce(Result<Vec<(BookInfo, u64)>, GetBookRangeError>) + Send>,
    ) -> JoinHandle<()>;
}
