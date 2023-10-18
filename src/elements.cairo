//
// Attribute
//

#[derive(Drop)]
struct Attribute {
    name: ByteArray,
    value: ByteArray
}

impl AttributeClone of Clone<Attribute> {
    fn clone(self: @Attribute) -> Attribute {
        Attribute { name: self.name.clone(), value: self.value.clone() }
    }
}

impl AttributeToBytes of super::ToBytes<Attribute> {
    #[inline]
    fn to_bytes(self: Attribute) -> ByteArray {
        self.name + "=\"" + self.value + "\""
    }
}

impl AttributeArrayToBytes of super::ToBytes<Array<Attribute>> {
    #[inline]
    fn to_bytes(mut self: Array<Attribute>) -> ByteArray {
        let mut s = "";
        loop {
            match self.pop_front() {
                Option::Some(attr) => { s += " " + attr.to_bytes(); },
                Option::None => { break; },
            };
        };

        s
    }
}

//
// Tag
//

#[derive(Drop)]
struct Tag {
    name: ByteArray,
    attrs: Option<Array<Attribute>>,
    children: Option<Array<Tag>>,
    content: Option<ByteArray>
}

impl TagClone of Clone<Tag> {
    fn clone(self: @Tag) -> Tag {
        let attrs = match self.attrs {
            Option::Some(attrs) => Option::Some(attrs.clone()),
            Option::None => Option::None
        };

        let children = match self.children {
            Option::Some(children) => Option::Some(children.clone()),
            Option::None => Option::None
        };

        let content = match self.content {
            Option::Some(content) => Option::Some(content.clone()),
            Option::None => Option::None
        };

        Tag { name: self.name.clone(), attrs, children, content }
    }
}

impl TagToBytes of super::ToBytes<Tag> {
    #[inline]
    fn to_bytes(self: Tag) -> ByteArray {
        self.build()
    }
}

impl TagArrayToBytes of super::ToBytes<Array<Tag>> {
    fn to_bytes(mut self: Array<Tag>) -> ByteArray {
        let mut s = "";
        loop {
            match self.pop_front() {
                Option::Some(tag) => { s += tag.to_bytes(); },
                Option::None => { break; },
            };
        };

        s
    }
}

//
// TagBuilder trait
//

trait TagBuilder<T> {
    fn new(name: ByteArray) -> T;
    fn build(self: T) -> ByteArray;
    fn attr(self: T, name: ByteArray, value: ByteArray) -> T;
    fn content(self: T, content: ByteArray) -> T;
    fn insert(self: T, child: T) -> T;
}

impl TagImpl of TagBuilder<Tag> {
    fn new(name: ByteArray) -> Tag {
        Tag { name: name, attrs: Option::None, children: Option::None, content: Option::None }
    }

    fn build(self: Tag) -> ByteArray {
        if self.attrs.is_none() && self.children.is_none() && self.content.is_none() {
            return "<" + self.name + " />";
        }

        let Tag{name, attrs, children, content } = self;

        let mut s = "<" + name.clone();

        if attrs.is_some() {
            s += attrs.unwrap().to_bytes();
        }

        if children.is_none() && content.is_none() {
            return s + " />";
        } else {
            s += ">";
        }

        if children.is_some() {
            s += children.unwrap().to_bytes();
        }

        if content.is_some() {
            s += content.unwrap();
        }

        s + "</" + name + ">"
    }

    fn attr(mut self: Tag, name: ByteArray, value: ByteArray) -> Tag {
        let mut attrs = match self.attrs {
            Option::Some(attrs) => attrs,
            Option::None => { Default::default() }
        };

        attrs.append(Attribute { name, value });
        self.attrs = Option::Some(attrs);
        self
    }

    fn content(mut self: Tag, content: ByteArray) -> Tag {
        self.content = Option::Some(content);
        self
    }

    fn insert(mut self: Tag, child: Tag) -> Tag {
        let mut children = match self.children {
            Option::Some(children) => children,
            Option::None => { Default::default() }
        };

        children.append(child);
        self.children = Option::Some(children);
        self
    }
}

#[cfg(test)]
mod tests {
    use super::{Tag, TagImpl};

    #[test]
    #[available_gas(1000000)]
    fn test_new() {
        let tag: Tag = TagImpl::new("html");
        assert(tag.name == "html", 'name');
        assert(tag.attrs.is_none(), 'attrs');
        assert(tag.children.is_none(), 'children');
        assert(tag.content.is_none(), 'content');
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
        assert(rect.build() == "<rect width=\"200\" />", 'build rect 1');

        // with two attrs
        let rect: Tag = TagImpl::new("rect").attr("width", "200").attr("height", "100");
        assert(rect.build() == "<rect width=\"200\" height=\"100\" />", 'build rect 2');
    }

    #[test]
    #[available_gas(100000000)]
    fn test_build_with_content() {
        let div: Tag = TagImpl::new("div").content("Hello, world!");
        assert(div.content.is_some(), 'content is some');
        assert(div.build() == "<div>Hello, world!</div>", 'build div');
    }

    #[test]
    #[available_gas(100000000)]
    fn test_build_with_attrs_and_content() {
        let div: Tag = TagImpl::new("div").attr("class", "big").content("Hello, world!");
        assert(div.attrs.is_some(), 'attrs len 1');
        assert(div.content.is_some(), 'content is some');
        assert(div.build() == "<div class=\"big\">Hello, world!</div>", 'build div');
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

    #[test]
    #[available_gas(100000000)]
    fn test_build_multiple_children_and_attrs() {
        let body: Tag = TagImpl::new("body");
        let h1: Tag = TagImpl::new("h1").attr("class", "main").attr("title", "heading");
        let h2: Tag = TagImpl::new("h2").attr("class", "sub").attr("title", "subtitle");
        let p: Tag = TagImpl::new("p");
        let text: Tag = TagImpl::new("text").attr("class", "r");

        let built = body.insert(h1).insert(h2).insert(p.insert(text)).build();
        assert(
            built == "<body><h1 class=\"main\" title=\"heading\" /><h2 class=\"sub\" title=\"subtitle\" /><p><text class=\"r\" /></p></body>",
            'built'
        );
    }

    #[test]
    #[available_gas(100000000)]
    fn test_build_mega() {
        let html: Tag = TagImpl::new("html");
        let head: Tag = TagImpl::new("head");
        let meta: Tag = TagImpl::new("meta")
            .attr("name", "keywords")
            .attr("content", "graffiti, cairo, starknet");
        let body: Tag = TagImpl::new("body");
        let h1: Tag = TagImpl::new("h1")
            .attr("class", "main")
            .attr("title", "heading")
            .content("This");
        let h2: Tag = TagImpl::new("h2")
            .attr("class", "sub")
            .attr("title", "subtitle")
            .content("What");
        let p: Tag = TagImpl::new("p").content("Hello, world!");
        let text_content =
            "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer convallis elit eu libero commodo";
        let text: Tag = TagImpl::new("text").attr("class", "r").content(text_content);
        let footer: Tag = TagImpl::new("footer")
            .attr("id", "f1")
            .content("The quick brown fox jumps over the lazy dog.");

        let page = html
            .insert(head.insert(meta))
            .insert(body.insert(h1).insert(h2).insert(p.insert(text)).insert(footer));
        assert(
            page
                .build() == "<html><head><meta name=\"keywords\" content=\"graffiti, cairo, starknet\" /></head><body><h1 class=\"main\" title=\"heading\">This</h1><h2 class=\"sub\" title=\"subtitle\">What</h2><p><text class=\"r\">Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer convallis elit eu libero commodo</text>Hello, world!</p><footer id=\"f1\">The quick brown fox jumps over the lazy dog.</footer></body></html>",
            'built'
        );
    }
}
