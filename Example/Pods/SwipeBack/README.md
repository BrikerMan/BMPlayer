SwipeBack
=========

[![CocoaPods](http://img.shields.io/cocoapods/v/SwipeBack.svg?style=flat)](http://cocoapods.org/?q=name%3ASwipeBack%20author%3Adevxoul)

Enable iOS7 swipe-to-back when custom back button is set.

> SwipeBack plays with iOS native gesture recognizers, so you can also use it to disable swipe-to-back feature.


Getting Started
---------------

Use [CocoaPods](http://cocoapods.org).

#### Podfile

```ruby
platform :ios, '7.0'
pod 'SwipeBack', '~> 1.1'
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
