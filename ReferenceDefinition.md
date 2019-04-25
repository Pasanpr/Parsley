## Reference Definition

A Markdown reference definition is how links are typically defined: `[Foo](http://foo.com)`

Reference definitions can take three forms:

**Full**

In the full form a ref def includes a link text "foo" inside square brackets followed by a link label "bar", also inside square brackets: `[foo][bar]`

Elswhere in the doc, the link label "bar", proves the link reference definition.

`[bar]: /url "title"`

**Collapsed**

A collapsed ref def consists of a link label that matches the link text.

Inline: `[foo][]`

`[foo]: /url "title"`

In this case `[foo][]` is equivalent to `[foo][foo]`.

**Shortcut**

In a shortcut ref def, there is no link label specified and the link text is used much like the collapsed ref def

Inline: `[foo]`

`[foo]: /url "title"`

In this case `[foo]` is equivalent to `[foo][]` which resolves to `[foo][foo]`.
