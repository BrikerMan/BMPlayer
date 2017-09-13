//
//  VIResourceLoaderManager.h
//  VIMediaCacheDemo
//
//  Created by Vito on 4/21/16.
//  Copyright © 2016 Vito. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AVFoundation;
@protocol VIResourceLoaderManagerDelegate;

@interface VIResourceLoaderManager : NSObject <AVAssetResourceLoaderDelegate>


@property (nonatomic, weak) id<VIResourceLoaderManagerDelegate> delegate;

/**
 Normally you no need to call this method to clean cache. Cache cleaned after AVPlayer delloc.
 If you have a singleton AVPlayer then you need call this method to clean cache at suitable time.
 */
- (void)cleanCache;

/**
 Cancel all downloading loaders.
 */
- (void)cancelLoaders;

@end

@protocol VIResourceLoaderManagerDelegate <NSObject>

- (void)resourceLoaderManagerLoadURL:(NSURL *)url didFailWithError:(NSError *)error;

@end

@interface VIResourceLoaderManager (Convenient)

+ (NSURL *)assetURLWithURL:(NSURL *)url;
- (AVPlayerItem *)playerItemWithURL:(NSURL *)url;

@end
