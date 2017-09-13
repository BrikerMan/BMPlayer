//
//  VIResoureLoader.h
//  VIMediaCacheDemo
//
//  Created by Vito on 4/21/16.
//  Copyright © 2016 Vito. All rights reserved.
//

#import <Foundation/Foundation.h>
@import AVFoundation;
@protocol VIResourceLoaderDelegate;

@interface VIResourceLoader : NSObject

@property (nonatomic, strong, readonly) NSURL *url;
@property (nonatomic, weak) id<VIResourceLoaderDelegate> delegate;

- (instancetype)initWithURL:(NSURL *)url;

- (void)addRequest:(AVAssetResourceLoadingRequest *)request;
- (void)removeRequest:(AVAssetResourceLoadingRequest *)request;

- (void)cancel;

@end

@protocol VIResourceLoaderDelegate <NSObject>

- (void)resourceLoader:(VIResourceLoader *)resourceLoader didFailWithError:(NSError *)error;

@end
