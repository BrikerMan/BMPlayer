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

#import "VIMediaCache.h"
#import "NSString+VIMD5.h"
#import "VICacheAction.h"
#import "VICacheConfiguration.h"
#import "VICacheManager.h"
#import "VICacheSessionManager.h"
#import "VIMediaCacheWorker.h"
#import "VIContentInfo.h"
#import "VIMediaDownloader.h"
#import "VIResourceLoader.h"
#import "VIResourceLoaderManager.h"
#import "VIResourceLoadingRequestWorker.h"

FOUNDATION_EXPORT double VIMediaCacheVersionNumber;
FOUNDATION_EXPORT const unsigned char VIMediaCacheVersionString[];

