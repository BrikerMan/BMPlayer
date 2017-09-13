//
//  VICacheAction.h
//  VIMediaCacheDemo
//
//  Created by Vito on 4/21/16.
//  Copyright © 2016 Vito. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, VICacheAtionType) {
    VICacheAtionTypeLocal = 0,
    VICacheAtionTypeRemote
};

@interface VICacheAction : NSObject

- (instancetype)initWithActionType:(VICacheAtionType)actionType range:(NSRange)range;

@property (nonatomic) VICacheAtionType actionType;
@property (nonatomic) NSRange range;

@end
