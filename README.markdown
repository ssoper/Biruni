## Biruni - Simple RSS parsing in Objective-c using blocks

### Installation
TODO

### Use
Let's say you have an RSS feed that looks like this

    <xml>
      <categories>
        <category>
          <name>Science</name>
          <link>/science</link>
        </category>
        <category>
          <name>Sports</name>
          <link>/sports</link>
        </category>
      </categories>
    </xml>

Grabbing this is as simple as 

    
    [Biruni parseWithFeedURL: @"http://url/feed" andTags: @"name,link" andBlock: ^(NSArray *results) {
      for (id category in results) {
        NSLog(@"Name: %@ and Link: %@", [result objectForKey: @"name"], [result objectForKey: @"link"]);
      }
    }];

