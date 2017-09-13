//
//  VICacheSessionManager.m
//  VIMediaCacheDemo
//
//  Created by Vito on 4/21/16.
//  Copyright © 2016 Vito. All rights reserved.
//

#import "VICacheSessionManager.h"

@interface VICacheSessionManager ()

@property (nonatomic, strong) NSOperationQueue *downloadQueue;

@end

@implementation VICacheSessionManager

+ (instancetype)shared {
    static id instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    
    return instance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
        queue.name = @"com.vimediacache.download";
        _downloadQueue = queue;
    }
    return self;
}

@end
