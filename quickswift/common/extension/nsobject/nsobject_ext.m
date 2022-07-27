//
//  nsobject_ext.m
//  common
//
//  Created by suyikun on 2022/7/27.
//

#import "nsobject_ext.h"
#import <Foundation/Foundation.h>

@implementation nsobject_ext

@end

@implementation NSObject (Catch)

- (nullable id)safeValueForKey:(NSString *_Nullable)key {
    return [NSObject ignoreError:^id _Nullable{
        return [self valueForKey:key];
    }];
}

+ (nullable id)ignoreError:(id _Nullable (^_Nonnull)(void))block {
    @try {
        return block();
    } @catch (NSException *exception) {
        NSLog(@"catch error: \(%@)", exception);
    } @finally {
        
    }
}

@end
