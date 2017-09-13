//
//  VIResoureLoader.m
//  VIMediaCacheDemo
//
//  Created by Vito on 4/21/16.
//  Copyright © 2016 Vito. All rights reserved.
//

#import "VIResourceLoader.h"
#import "VIMediaDownloader.h"
#import "VIResourceLoadingRequestWorker.h"
#import "VIContentInfo.h"

NSString * const MCResourceLoaderErrorDomain = @"LSFilePlayerResourceLoaderErrorDomain";

@interface VIResourceLoader () <VIResourceLoadingRequestWorkerDelegate>

@property (nonatomic, strong, readwrite) NSURL *url;
@property (nonatomic, strong) VIMediaDownloader *mediaDownloader;
@property (nonatomic, strong) NSMutableDictionary *pendingRequestWorkers;

@property (nonatomic, getter=isCancelled) BOOL cancelled;

@end

@implementation VIResourceLoader


- (void)dealloc {
    [_mediaDownloader invalidateAndCancel];
}

- (instancetype)initWithURL:(NSURL *)url {
    self = [super init];
    if (self) {
        _url = url;
        _mediaDownloader = [[VIMediaDownloader alloc] initWithURL:url];
        _pendingRequestWorkers = [NSMutableDictionary dictionary];
    }
    return self;
}

- (instancetype)init {
    NSAssert(NO, @"Use - initWithURL: instead");
    return nil;
}

- (void)addRequest:(AVAssetResourceLoadingRequest *)request {
    [self.pendingRequestWorkers enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, VIResourceLoadingRequestWorker * _Nonnull obj, BOOL * _Nonnull stop) {
        [obj cancel];
        [obj finish];
    }];
    [self.pendingRequestWorkers removeAllObjects];
    
    [self startWorkerWithRequest:request];
}

- (void)removeRequest:(AVAssetResourceLoadingRequest *)request {
    NSString *key = [self keyForRequest:request];
    VIResourceLoadingRequestWorker *requestWorker = self.pendingRequestWorkers[key];
    [requestWorker finish];
    
    [self.pendingRequestWorkers removeObjectForKey:key];
}

- (void)cancel {
    [self.mediaDownloader cancel];
}

#pragma mark - VIResourceLoadingRequestWorkerDelegate

- (void)resourceLoadingRequestWorker:(VIResourceLoadingRequestWorker *)requestWorker didCompleteWithError:(NSError *)error {
    [self removeRequest:requestWorker.request];
    if (error && [self.delegate respondsToSelector:@selector(resourceLoader:didFailWithError:)]) {
        [self.delegate resourceLoader:self didFailWithError:error];
    }
}

#pragma mark - Helper

- (void)startWorkerWithRequest:(AVAssetResourceLoadingRequest *)request {
    NSString *key = [self keyForRequest:request];
    VIResourceLoadingRequestWorker *requestWorker = [[VIResourceLoadingRequestWorker alloc] initWithMediaDownloader:self.mediaDownloader
                                                                                             resourceLoadingRequest:request];
    requestWorker.delegate = self;
    self.pendingRequestWorkers[key] = requestWorker;
    [requestWorker startWork];
}

- (NSString *)keyForRequest:(AVAssetResourceLoadingRequest *)request {
    return [NSString stringWithFormat:@"%@%@", request.request.URL.absoluteString, request.request.allHTTPHeaderFields[@"Range"]];
}

- (NSError *)loaderCancelledError{
    NSError *error = [[NSError alloc] initWithDomain:MCResourceLoaderErrorDomain
                                                code:-3
                                            userInfo:@{NSLocalizedDescriptionKey:@"Resource loader cancelled"}];
    return error;
}

@end
