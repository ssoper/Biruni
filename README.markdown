## Biruni - Simple RSS parsing in Objective-C using blocks

### Installation
TODO

### Use
Let's say you have an RSS feed that looks like this

    <?xml version="1.0" encoding="UTF-8"?>
    <rss>
      <item>
        <title>Bringing up Baby</title>
        <year>1938</year>
      </item>
      <item>
        <title>His Girl Friday</title>
        <year>1940</year>
      </item>
      <item>
        <title>Arsenic and Old Lace</title>
        <year>1944</year>
      </item>
    </rss>

Grabbing it is as simple as

    [Biruni parseURL: @"http://url/feed" tags: @"title,year" block: ^(NSArray *results) {
      for (id result in results) {
        NSLog(@"Movie: %@ (%@)", [result title], [result year]);
      }
    }];
