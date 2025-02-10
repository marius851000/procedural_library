use std::{io::Read, thread::JoinHandle};

use rand::{Rng, SeedableRng};
use rand_chacha::ChaCha20Rng;
use serde::Deserialize;

use crate::{book_library_database::GetBookRangeError, BookInfo, BookLibraryDatabase};

use super::{AnnaMetadata, LoadAnnaMetadataError};

#[derive(Deserialize)]
struct AnnaBloomsburyMetaFormat {
    metadata: AnnaBloomsburyMetaFormatInternal,
}

#[derive(Deserialize)]
struct AnnaBloomsburyMetaFormatInternal {
    #[serde(rename = "Title")]
    title: String,
}

pub struct AnnaBloomsburyMetadata {
    anna_metadata: AnnaMetadata,
}

impl AnnaBloomsburyMetadata {
    pub fn new<R: Read>(reader: R) -> Result<Self, LoadAnnaMetadataError> {
        Ok(Self {
            anna_metadata: AnnaMetadata::new(reader, |line, book_id| {
                let parsed = serde_json::from_str::<AnnaBloomsburyMetaFormat>(line)?;
                
                Ok(BookInfo {
                    title: parsed.metadata.title,
                    width: ChaCha20Rng::seed_from_u64(book_id).random_range(5..=25),
                })
            })?,
        })
    }
}

impl BookLibraryDatabase for AnnaBloomsburyMetadata {
    fn get_library_length(&self) -> u64 {
        self.anna_metadata.get_library_length()
    }

    fn get_book_range_from_distance(
        &self,
        start_inclusive: u64,
        count: u64,
        always_return_one_book: bool,
        callback: Box<dyn FnOnce(Result<Vec<(BookInfo, u64)>, GetBookRangeError>) + Send>,
    ) -> JoinHandle<()> {
        self.anna_metadata.get_book_range_from_distance(
            start_inclusive,
            count,
            always_return_one_book,
            callback,
        )
    }
}
