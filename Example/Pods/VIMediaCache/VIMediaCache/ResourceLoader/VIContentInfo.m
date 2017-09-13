//
//  VIContentInfo.m
//  VIMediaCacheDemo
//
//  Created by Vito on 4/21/16.
//  Copyright © 2016 Vito. All rights reserved.
//

#import "VIContentInfo.h"

static NSString *kContentLengthKey = @"kContentLengthKey";
static NSString *kContentTypeKey = @"kContentTypeKey";
static NSString *kByteRangeAccessSupported = @"kByteRangeAccessSupported";

@implementation VIContentInfo

- (NSString *)debugDescription {
    return [NSString stringWithFormat:@"%@\ncontentLength: %lld\ncontentType: %@\nbyteRangeAccessSupported:%@", NSStringFromClass([self class]), self.contentLength, self.contentType, @(self.byteRangeAccessSupported)];
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:@(self.contentLength) forKey:kContentLengthKey];
    [aCoder encodeObject:self.contentType forKey:kContentTypeKey];
    [aCoder encodeObject:@(self.byteRangeAccessSupported) forKey:kByteRangeAccessSupported];
}

- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    if (self) {
        _contentLength = [[aDecoder decodeObjectForKey:kContentLengthKey] longLongValue];
        _contentType = [aDecoder decodeObjectForKey:kContentTypeKey];
        _byteRangeAccessSupported = [[aDecoder decodeObjectForKey:kByteRangeAccessSupported] boolValue];
    }
    return self;
}

@end
