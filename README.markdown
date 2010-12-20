## Biruni - Simple RSS parsing in Objective-C using blocks

### Overview
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

### Adding Biruni to your project
1. Clone the Biruni git repository: `git://github.com/ssoper/Biruni.git`.
2. In the project that you want to add Biruni to, create a new group labeled `Biruni`.
3. Open the Biruni project in Xcode and drag the files under `Classes` into the `Biruni` group in your project.
4. You're all set, just add `#import "Biruni.h"` anywhere you want to use it in your project.
