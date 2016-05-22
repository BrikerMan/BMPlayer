SwipeBack
=========

[![CocoaPods](http://img.shields.io/cocoapods/v/SwipeBack.svg?style=flat)](http://cocoapods.org/?q=name%3ASwipeBack%20author%3Adevxoul)

Enable iOS7 swipe-to-back when custom back button is set.

Getting Started
---------------

Use [CocoaPods](http://cocoapods.org).

#### Podfile

```ruby
platform :ios, '7.0'
pod 'SwipeBack', '~> 1.0'
```

Usage
-----

### Basic Usage

Just install SwipeBack with CocoaPods. Your application now supports swipe-to-back feature.

### Enabling and Disabling

You can set `swipeBackEnabled` for a specific `UINavigationController`. Default value is `YES`.

```objc
#import <SwipeBack/SwipeBack.h>

// ...

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.swipeBackEnabled = NO;
}
```

License
-------

SwipeBack is under MIT license. See [LICENSE](https://github.com/devxoul/SwipeBack/blob/master/LICENSE) for more info.
