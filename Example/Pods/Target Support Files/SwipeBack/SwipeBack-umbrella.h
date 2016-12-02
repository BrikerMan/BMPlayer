#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "SwipeBack.h"
#import "UINavigationController+SwipeBack.h"
#import "UIViewController+SwipeBack.h"

FOUNDATION_EXPORT double SwipeBackVersionNumber;
FOUNDATION_EXPORT const unsigned char SwipeBackVersionString[];

