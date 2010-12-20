### TODO

1. Add parsing/coercion for common data types in RSS feeds such as dates and numbers.
2. To take into account nodes with the same tag that appear multiple times in a single parent node, the parsing method will need to be switched out to rely on depth rather than repetition of a tag.
3. Nodes which appear multiple times should be returned as an array of NS objects. In this case, category should come back as an array of NSStrings.

    <article>
      <category>Sports</category>
      <category>Science</category>
      <name>News</news>
    </article>
    
4. Look into using NSInvocation to avoid users having to do the [result objectForKey:@"property"] pattern. We'd rather use result.property.
