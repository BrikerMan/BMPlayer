//
//  NSString+VIMD5.m
//  VIMediaCacheDemo
//
//  Created by Vito on 21/11/2017.
//  Copyright © 2017 Vito. All rights reserved.
//

#import "NSString+VIMD5.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (VIMD5)

- (NSString *)vi_md5 {
    const char* str = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(str, (CC_LONG)strlen(str), result);
    
    NSMutableString *ret = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH*2];
    for(int i = 0; i<CC_MD5_DIGEST_LENGTH; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

@end

