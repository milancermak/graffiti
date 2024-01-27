mod constants {
    const BRACKET_OPEN: felt252 = '{';
    const BRACKET_CLOSE: felt252 = '}';

    const QUOTE: felt252 = '"';
    const COLON: felt252 = ':';
    const COMMA: felt252 = ',';

    const NAME: felt252 = 'name';
    const DESCRIPTION: felt252 = 'description';
    const IMAGE: felt252 = 'image';
    const ATTRIBUTES: felt252 = 'attributes';

    const TRAIT_TYPE: felt252 = 'trait_type';
    const VALUE: felt252 = 'value';

    const SQUARE_BRACKET_OPEN: felt252 = '[';
    const SQUARE_BRACKET_CLOSE: felt252 = ']';
}

// Check if a string starts with a bracket (either square or curly)
fn starts_with_bracket(str: @ByteArray) -> bool {
    if str.len() == 0 {
        return false;
    }
    match str.at(0) {
        Option::Some(first_letter) => {
            if (first_letter.into() == constants::SQUARE_BRACKET_OPEN)
                || (first_letter.into() == constants::BRACKET_OPEN) {
                true
            } else {
                false
            }
        },
        Option::None => false
    }
}