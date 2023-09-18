#[derive(Default, Drop)]
struct Attribute {
    name: ByteArray,
    value: ByteArray
}

#[derive(Drop)]
struct Tag {
    name: ByteArray,
    attrs: Array<Attribute>,
    children: Option<Array<Tag>>
}

trait TagBuilder<T> {
    fn new(name: ByteArray) -> T;
    fn build(self: T) -> ByteArray;
    fn attr(self: T, name: ByteArray, value: ByteArray) -> T;
}

impl TagImpl of TagBuilder<Tag> {
    fn new(name: ByteArray) -> Tag {
        Tag {
            name: name,
            attrs: Default::default(),
            children: Option::None
        }
    }

    fn build(self: Tag) -> ByteArray {
        if self.attrs.len().is_zero() {
            return "<" + self.name + " />";
        }

        let mut s = "<" + self.name;
        let mut attrs = self.attrs.span();
        loop {
            match attrs.pop_front() {
                Option::Some(attr) => {
                    s += " " + attr.name.clone() + "=\"" + attr.value.clone() + "\"";
                },
                Option::None => {
                    s += " />";
                    break;
                },
            };
        };

        s
    }

    fn attr(mut self: Tag, name: ByteArray, value: ByteArray) -> Tag {
        self.attrs.append(Attribute { name, value });
        self
    }
}

#[cfg(test)]
mod tests {
    use super::{Attribute, Tag, TagImpl};

    #[test]
    #[available_gas(1000000)]
    fn test_new() {
        let tag: Tag = TagImpl::new("html");
        assert(tag.name == "html", 'name');
        assert(tag.attrs.len() == 0, 'attrs len');
        assert(tag.children.is_none(), 'children');
    }

    #[test]
    #[available_gas(1000000)]
    fn test_build_empty() {
        let tag: Tag = TagImpl::new("html");
        assert(tag.build() == "<html />", 'build');
    }

    #[test]
    #[available_gas(100000000)]
    fn test_build_with_attrs() {
        // with just one attr
        let rect: Tag = TagImpl::new("rect").attr("width", "200");
        assert(rect.attrs.len() == 1, 'attrs len 1');
        assert(rect.build() == "<rect width=\"200\" />", 'build rect 1');

        // with two attrs
        let rect: Tag = TagImpl::new("rect").attr("width", "200").attr("height", "100");
        assert(rect.attrs.len() == 2, 'attrs len 2');
        assert(rect.build() == "<rect width=\"200\" height=\"100\" />", 'build rect 2');
    }
}
