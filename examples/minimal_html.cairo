use graffiti::{Tag, TagImpl};

fn minimal_html() -> ByteArray {
    // <html lang="en">
    let mut html: Tag = TagImpl::new("html").attr("lang", "en");

    // <head>
    //   <meta charset="utf-8">
    //   <title>Built by Graffiti</title>
    //   <link rel="stylesheet" href="style.css">
    //   <script src="script.js"></script>
    // </head>
    let mut head: Tag = TagImpl::new("head");
    let meta: Tag = TagImpl::new("meta").attr("charset", "utf-8");
    let title: Tag = TagImpl::new("title").content("Built by Graffiti");
    let link: Tag = TagImpl::new("link").attr("rel", "stylesheet").attr("href", "style.css");
    let script: Tag = TagImpl::new("script").attr("src", "script.js");
    head = head.insert(meta).insert(title).insert(link).insert(script);

    // <body><p>Hello, world!<p></body>
    let p: Tag = TagImpl::new("p").content("Hello, world!");
    let body: Tag = TagImpl::new("body").insert(p);

    // build the full HTML document
    html.insert(head).insert(body).build()
}
