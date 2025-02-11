use std::{io::Read, thread::JoinHandle};

use rand::{Rng, SeedableRng};
use rand_chacha::ChaCha20Rng;
use serde::Deserialize;
use thiserror::Error;

use crate::{BookInfo, BookLibraryDatabase, GetBookRangeError};

use super::VecBasedBookLibraryDatabase;

#[derive(Error, Debug)]
pub enum LoadProjectGutenbergCsvCatalogError {
    #[error("IO Error: {0}")]
    IoError(#[from] std::io::Error),
    #[error("CSV Error: {0}")]
    CsvError(#[from] csv::Error),
}

#[derive(Deserialize, Debug)]
pub struct ProjectGutenbergBookInfo {
    #[serde(rename = "Text#")]
    pub document_number: u64,
    #[serde(rename = "Type")]
    pub document_type: String,
    #[serde(rename = "Title")]
    pub title: String,
    #[serde(rename = "Language")]
    pub _language: String,
    #[serde(rename = "Authors")]
    pub _authors: String,
    #[serde(rename = "Subjects")]
    pub _subjects: String,
    #[serde(rename = "LoCC")]
    pub _locc: String,
    #[serde(rename = "Bookshelves")]
    pub _bookshelves: String,
}

pub struct ProjectGutenbergCsvCatalog {
    inner: VecBasedBookLibraryDatabase,
}

impl ProjectGutenbergCsvCatalog {
    pub fn new<F: Read>(input: &mut F) -> Result<Self, LoadProjectGutenbergCsvCatalogError> {
        let mut result = Vec::new();
        let mut rdr = csv::Reader::from_reader(input);
        for book in rdr.deserialize::<ProjectGutenbergBookInfo>() {
            let book = book?;
            if book.document_type == "Text" {
                result.push(BookInfo {
                    title: book.title,
                    width: ChaCha20Rng::seed_from_u64(book.document_number).random_range(5..=25),
                })
            }
        }

        Ok(Self {
            inner: VecBasedBookLibraryDatabase::new(result),
        })
    }
}

impl BookLibraryDatabase for ProjectGutenbergCsvCatalog {
    fn get_library_length(&self) -> u64 {
        self.inner.get_library_length()
    }

    fn get_book_range_from_distance(
        &self,
        start_inclusive: u64,
        count: u64,
        always_return_one_book: bool,
        callback: Box<dyn FnOnce(Result<Vec<(BookInfo, u64)>, GetBookRangeError>) + Send>,
    ) -> JoinHandle<()> {
        self.inner.get_book_range_from_distance(
            start_inclusive,
            count,
            always_return_one_book,
            callback,
        )
    }
}
