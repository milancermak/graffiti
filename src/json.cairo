use graffiti::utils::constants::{
    BRACKET_OPEN, BRACKET_CLOSE, QUOTE, COLON, COMMA, SQUARE_BRACKET_OPEN, SQUARE_BRACKET_CLOSE
};
use graffiti::utils::starts_with_bracket;


#[derive(Drop)]
struct JsonBuilder {
    data: Array<Attribute>
}

impl JsonBuilderDefault of Default<JsonBuilder> {
    fn default() -> JsonBuilder {
        JsonBuilder { data: array![] }
    }
}


#[derive(Drop)]
struct Attribute {
    key: ByteArray,
    value: ByteArray
}

trait AttributeTrait<Attribute> {
    fn to_bytes(self: Attribute) -> ByteArray;
}

impl AttributeImpl of AttributeTrait<Attribute> {

    fn to_bytes(mut self: Attribute) -> ByteArray {
        let mut ba1 = Default::default();

        ba1.append_word(QUOTE, 1);
        ba1.append(@self.key);
        ba1.append_word(QUOTE, 1);
        ba1.append_word(COLON, 1);

        if starts_with_bracket(@self.value) {
            ba1.append(@self.value);
        } else {
            ba1.append_word(QUOTE, 1);
            ba1.append(@self.value);
            ba1.append_word(QUOTE, 1);
        }        
        ba1
    }
}

trait Builder<T> {
    fn new() -> T;
    fn add(self: T, key: ByteArray, value: ByteArray) -> T;
    fn add_array(self: T, key: ByteArray, value: Span<ByteArray>) -> T;
    fn build(self: T) -> ByteArray;
}


impl JsonImpl of Builder<JsonBuilder> {
    fn new() -> JsonBuilder {
        JsonBuilder { data: array![] }
    }

    fn add(mut self: JsonBuilder, key: ByteArray, value: ByteArray) -> JsonBuilder {
        self.data.append(Attribute { key, value});
        self
    }

    fn add_array(mut self: JsonBuilder, key: ByteArray, mut value: Span<ByteArray>) -> JsonBuilder {
        let mut str: ByteArray = "";
        str.append_word(SQUARE_BRACKET_OPEN, 1);
        loop {
            match value.pop_front() {
                Option::Some(v) => {
                    if starts_with_bracket(v) {
                        str.append(v);
                    } else {
                        str.append_word(QUOTE, 1);
                        str.append(v);
                        str.append_word(QUOTE, 1);
                    }
                    if value.len() > 0 {
                        str.append_word(COMMA, 1);
                    }
                },
                Option::None => { 
                    str.append_word(SQUARE_BRACKET_CLOSE, 1);
                    break;
                },
            };
        };

        self.data.append(Attribute { key, value: str});
        self
    }



    fn build(mut self: JsonBuilder) -> ByteArray {
        let mut ba1 = Default::default();

        ba1.append_word(BRACKET_OPEN, 1);

        loop {
            match self.data.pop_front() {
                Option::Some(attr) => {
                    ba1.append(@attr.to_bytes());
                    if self.data.len() > 0 {
                        ba1.append_word(COMMA, 1);
                    }
                },
                Option::None => { break; },
            };
        };

        ba1.append_word(BRACKET_CLOSE, 1);

        ba1
    }
}

#[cfg(test)]
mod tests {
    use super::JsonImpl;

    #[test]
    fn test_add() {
        let data = JsonImpl::new()
            .add("name", "Token Name")
            .add("description", "A description of what this token represents")
            .build();

        assert!(
            data == "{\"name\":\"Token Name\",\"description\":\"A description of what this token represents\"}", 
            "wrong json data"
        );

        println!("json: {}", data);
    }

    #[test]
    fn test_add_array() {

        let sub = JsonImpl::new()
                    .add("streetAddress", "21 2nd Street")
                    .add("city", "San Bryyy")
                    .build();
        let mainarr 
            = JsonImpl::new()
            .add("firstName", "John")
            .add("lastName", "Kevin")
            .add("address", sub.clone())
            .add_array("lsit_of_str", array!["trait_type", "Base", "value", "Starfish"].span())
            .add_array("attributes", array![sub.clone(), sub.clone()].span())
            .add("safety", "Green");

        let z = mainarr.build();

        assert!(
            z == "{\"firstName\":\"John\",\"lastName\":\"Kevin\",\"address\":{\"streetAddress\":\"21 2nd Street\",\"city\":\"San Bryyy\"},\"lsit_of_str\":[\"trait_type\",\"Base\",\"value\",\"Starfish\"],\"attributes\":[{\"streetAddress\":\"21 2nd Street\",\"city\":\"San Bryyy\"},{\"streetAddress\":\"21 2nd Street\",\"city\":\"San Bryyy\"}],\"safety\":\"Green\"}", 
            "wrong json data"
        );

        println!("\n\njson: {}\n\n", z);       
    }
}
