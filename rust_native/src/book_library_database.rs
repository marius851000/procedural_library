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
     * Book occupy a range as in book_distance=..=(next_book_distance - 1)
     * The first book taken is the one that occupy the start range
     * The last book is the one that occupy the book before the last range. (so a range from 10 with a length of 50 will have books that occupy a total of less than or equal to 50 millimeter, or a single book if the book is more than 50 mm wide.)
     * if always_return_one_book is true, it instead return only the first book, ignoring the distance
     * always_return_one_book is false, return no book when last book if before the first book
     */
    fn get_book_range_from_distance(
        &self,
        start_inclusive: u64,
        length: u64,
        always_return_one_book: bool,
        callback: Box<dyn FnOnce(Result<Vec<(BookInfo, u64)>, GetBookRangeError>) + Send>,
    ) -> JoinHandle<()>;
}
