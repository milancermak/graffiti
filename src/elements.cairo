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
    fn insert(self: T, child: T) -> T;
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
        if self.attrs.len().is_zero() && self.children.is_none() {
            return "<" + self.name + " />";
        }

        let mut s = "<" + self.name.clone();
        let mut attrs = self.attrs.span();
        loop {
            match attrs.pop_front() {
                Option::Some(attr) => {
                    s += " " + attr.name.clone() + "=\"" + attr.value.clone() + "\"";
                },
                Option::None => {
                    if self.children.is_none() {
                        s += " />";
                    } else {
                        s += ">";
                        let mut children = self.children.unwrap();
                        loop {
                            match children.pop_front() {
                                Option::Some(child) => {
                                    s += child.build();
                                },
                                Option::None => {
                                    break;
                                },
                            };

                        };
                        s += "</" + self.name + ">";
                    }
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

    fn insert(mut self: Tag, child: Tag) -> Tag {
        let mut children = match self.children {
            Option::Some(children) => children,
            Option::None => {
                Default::default()
            }
        };

        children.append(child);
        self.children = Option::Some(children);

        self
    }
}

#[cfg(test)]
mod tests {
    use csvg::elements::TagBuilder;
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

    #[test]
    #[available_gas(100000000)]
    fn test_insert_one_child() {
        let mut html: Tag = TagImpl::new("html");
        let head: Tag = TagImpl::new("head");

        html = html.insert(head);
        assert(html.children.is_some(), 'children is some');
        assert(html.children.unwrap().len() == 1, 'children len 1');
    }

    #[test]
    #[available_gas(100000000)]
    fn test_insert_multiple_children() {
        let mut body: Tag = TagImpl::new("body");
        let h1: Tag = TagImpl::new("h1");
        let h2: Tag = TagImpl::new("h2");
        let p: Tag = TagImpl::new("p");

        body = body.insert(h1).insert(h2).insert(p);
        assert(body.children.is_some(), 'children is some');
        assert(body.children.unwrap().len() == 3, 'children len 3');
    }

    #[test]
    #[available_gas(100000000)]
    fn test_build_one_child_plain() {
        let html: Tag = TagImpl::new("html");
        let head: Tag = TagImpl::new("head");

        let built = html.insert(head).build();
        assert(built == "<html><head /></html>", 'built');
    }

    #[test]
    #[available_gas(100000000)]
    fn test_build_one_child_with_attrs() {
        let div: Tag = TagImpl::new("div");
        let p: Tag = TagImpl::new("p").attr("class", "foo").attr("id", "bar");

        let built = div.insert(p).build();
        assert(built == "<div><p class=\"foo\" id=\"bar\" /></div>", 'built');
    }

    use debug::PrintTrait;

    #[test]
    #[available_gas(100000000)]
    fn test_build_multiple_children_and_attrs() {
        let body: Tag = TagImpl::new("body");
        let h1: Tag = TagImpl::new("h1").attr("class", "main").attr("title", "heading");
        let h2: Tag = TagImpl::new("h2").attr("class", "sub").attr("title", "subtitle");
        let p: Tag = TagImpl::new("p");
        let text: Tag = TagImpl::new("text").attr("class", "r");

        let built = body.insert(h1).insert(h2).insert(p.insert(text)).build();
        assert(built == "<body><h1 class=\"main\" title=\"heading\" /><h2 class=\"sub\" title=\"subtitle\" /><p><text class=\"r\" /></p></body>", 'built');
    }
}
