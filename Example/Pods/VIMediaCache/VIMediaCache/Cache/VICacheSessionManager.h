//
//  VICacheSessionManager.h
//  VIMediaCacheDemo
//
//  Created by Vito on 4/21/16.
//  Copyright © 2016 Vito. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VICacheSessionManager : NSObject

@property (nonatomic, strong, readonly) NSOperationQueue *downloadQueue;

+ (instancetype)shared;

@end
