use std::{
    io::{BufRead, BufReader, Read},
    thread::JoinHandle,
};
use thiserror::Error;

use crate::{book_library_database::GetBookRangeError, BookInfo, BookLibraryDatabase};

use super::VecBasedBookLibraryDatabase;

#[derive(Error, Debug)]
pub enum LoadAnnaMetadataError {
    #[error("IO Error: {0}")]
    IoError(#[from] std::io::Error),
    #[error("Metadata parsing error")]
    BookInfoParseError(anyhow::Error),
}

/**
 * Unoptimised access to the file, for development or conversion purpose
 */
pub struct AnnaMetadata {
    books: VecBasedBookLibraryDatabase,
}

impl AnnaMetadata {
    pub fn new<R: Read, P: Fn(&str) -> Result<BookInfo, anyhow::Error>>(
        mut reader: R,
        parser: P,
    ) -> Result<Self, LoadAnnaMetadataError> {
        let mut books = Vec::new();
        for line in BufReader::new(&mut reader).lines() {
            let line = line?;

            let parsed = parser(&line).map_err(LoadAnnaMetadataError::BookInfoParseError)?;

            books.push(parsed);
        }

        Ok(Self {
            books: VecBasedBookLibraryDatabase::new(books),
        })
    }
}

impl BookLibraryDatabase for AnnaMetadata {
    fn get_book_count(&self) -> u64 {
        self.books.get_book_count()
    }

    fn get_book_range_from_distance(
        &self,
        start_inclusive: u64,
        count: u64,
        always_return_one_book: bool,
        callback: Box<dyn FnOnce(Result<Vec<(BookInfo, u64)>, GetBookRangeError>) + Send>,
    ) -> JoinHandle<()> {
        self.books.get_book_range_from_distance(
            start_inclusive,
            count,
            always_return_one_book,
            callback,
        )
    }
}
