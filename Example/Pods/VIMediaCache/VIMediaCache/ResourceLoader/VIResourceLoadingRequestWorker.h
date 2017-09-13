//
//  VIResourceLoadingRequestWorker.h
//  VIMediaCacheDemo
//
//  Created by Vito on 4/21/16.
//  Copyright © 2016 Vito. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VIMediaDownloader, AVAssetResourceLoadingRequest;
@protocol VIResourceLoadingRequestWorkerDelegate;

@interface VIResourceLoadingRequestWorker : NSObject

- (instancetype)initWithMediaDownloader:(VIMediaDownloader *)mediaDownloader resourceLoadingRequest:(AVAssetResourceLoadingRequest *)request;

@property (nonatomic, weak) id<VIResourceLoadingRequestWorkerDelegate> delegate;

@property (nonatomic, strong, readonly) AVAssetResourceLoadingRequest *request;

- (void)startWork;
- (void)cancel;
- (void)finish;

@end

@protocol VIResourceLoadingRequestWorkerDelegate <NSObject>

- (void)resourceLoadingRequestWorker:(VIResourceLoadingRequestWorker *)requestWorker didCompleteWithError:(NSError *)error;

@end
