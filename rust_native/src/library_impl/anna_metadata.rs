use std::io::{BufRead, BufReader, Read};
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

    fn get_book_range<F: FnOnce(Result<Vec<BookInfo>, GetBookRangeError>)>(
        &self,
        start_inclusive: u64,
        count: u64,
        callback: F,
    ) {
        self.books.get_book_range(start_inclusive, count, callback);
    }
}
