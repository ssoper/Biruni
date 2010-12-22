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
        NSLog(@"Movie: %@ (%@)", [result objectForKey:@"title"], [result objectForKey:@"year"]);
      }
    }];

### Adding Biruni to your project

#### Compile from source (iOS or Mac OSX)
1. Clone the Biruni git repository: `git://github.com/ssoper/Biruni.git`.
2. In the project that you want to add Biruni to, create a new group labeled `Biruni`.
3. Open the Biruni project in Xcode and drag the files under `Classes` into the `Biruni` group in your project.
4. You're all set, just add `#import "Biruni.h"` anywhere you want to use it in your project.

#### Embed the framework (Mac OSX)
1. Clone the Biruni git repository: `git://github.com/ssoper/Biruni.git`.
2. Open the `Biruni` project and build the framework.
3. Select `Products` &rarr; `Biruni.framework` &rarr; `Reveal in Finder`
4. In the project that you want to add Biruni to, browse to the project's root directory and create a directory called `Frameworks`.
5. Use Finder to drag the `Biruni.framework` directory into the `Frameworks` directory of your project.
6. In your Mac OSX project, open `Frameworks` &rarr; `Linked Frameworks`. Right-click on `Linked Frameworks`, select `Add` &rarr; `Existing Framework`.
5. Click on `Add Other…` on the bottom of the dialog, browse to the project's `Frameworks` directory and select `Biruni.framework`.
6. Expand `Targets`, right-click on your project's name and select `Add` &rarr; `New Build Phase` &rarr; `New Copy Files Build Phase`. Select `Frameworks` from the dropdown and close the dialog.
7. Now drag `Biruni.framework` from the `Linked Frameworks` group into this newly-created group which should be labeled `Copy Files`. Then take this same group and drag it to a spot above `Link Binary With Libraries` and any group named `Run Script`.
8. Right-click on your project's name underneath `Targets` and select `Get Info`. Modify the `Runtime search paths` value to include `@loader_path/../Frameworks`.
9. Add `#import <Biruni/Biruni.h>` to the top of any file where you want to include the functionality.

###  Notes
1. You don't have to list all the tags in an element, only those that you want returned.
2. You can run the included unit tests by selecting `BiruniTests` as your target and building.

### Namesake
<img src="http://upload.wikimedia.org/wikipedia/en/thumb/1/1e/Iran_Biruni.jpg/200px-Iran_Biruni.jpg" align="left" alt="Abu Rayhan Biruni" />
Abu Rayhan Biruni was a Persian scholar who lived during the Islamic Golden Age. Using a primitive tool known as an astrolabe and the power of his intellect, he was able to measure the diameter of the Earth to within ten miles of modern measurements. He reportedly developed this method to avoid "walking across hot, dusty deserts".
