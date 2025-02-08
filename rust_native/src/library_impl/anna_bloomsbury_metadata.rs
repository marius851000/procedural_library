use std::{io::Read, thread::JoinHandle};

use serde::Deserialize;

use crate::{
    book_library_database::GetBookRangeError, BookInfo, BookLibraryDatabase,
};

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
            anna_metadata: AnnaMetadata::new(reader, |line| {
                let parsed = serde_json::from_str::<AnnaBloomsburyMetaFormat>(line)?;

                Ok(BookInfo {
                    title: parsed.metadata.title,
                })
            })?,
        })
    }
}

impl BookLibraryDatabase for AnnaBloomsburyMetadata {
    fn get_book_count(&self) -> u64 {
        self.anna_metadata.get_book_count()
    }

    fn get_book_range(
        &self,
        start_inclusive: u64,
        count: u64,
        callback: Box<dyn FnOnce(Result<Vec<BookInfo>, GetBookRangeError>) + Send>,
    ) -> JoinHandle<()> {
        self.anna_metadata
            .get_book_range(start_inclusive, count, callback)
    }
}
