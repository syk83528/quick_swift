//
//  nsobject_ext.h
//  common
//
//  Created by suyikun on 2022/7/27.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface nsobject_ext : NSObject

@end

@interface NSObject (Catch)

- (nullable id)safeValueForKey:(NSString *_Nullable)key;
+ (nullable id)ignoreError:(id _Nullable (^_Nonnull)(void))block;

@end

NS_ASSUME_NONNULL_END
