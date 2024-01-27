trait ToBytes<T> {
    fn to_bytes(self: T) -> ByteArray;
}

mod elements;
use elements::{Tag, TagImpl};

mod json;
mod utils;