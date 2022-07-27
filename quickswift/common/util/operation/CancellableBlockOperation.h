//
//  CancellableBlockOperation.h
//  spsd
//
//  Created by Wildog on 1/4/20.
//  Copyright © 2020 Wildog. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CancellableBlockOperation : NSOperation

@property (nonatomic, copy, nullable) void (^block)(dispatch_semaphore_t _Nullable semaphore, CancellableBlockOperation * _Nonnull operation);
@property (nonatomic, strong, nullable) dispatch_semaphore_t semaphore;
@property (nonatomic, assign) NSTimeInterval timeout; // 0 = forever
@property (nonatomic, assign) BOOL __cancelled;
@property (nonatomic, strong, nullable) id context;
@property (nonatomic, strong, nullable) id createdBy;
@property (nonatomic, copy, nullable) NSString *identifier;
@property (nonatomic, assign) BOOL immediatelyStarted;
@property (nonatomic, assign) BOOL keepRunningInBackground;

+ (instancetype _Nonnull)operationWithBlock:(void (^_Nonnull)(dispatch_semaphore_t _Nullable semaphore, CancellableBlockOperation * _Nonnull operation))block timeout:(NSTimeInterval)timeout;
+ (instancetype _Nonnull)operationWithBlock:(void (^_Nonnull)(dispatch_semaphore_t _Nullable semaphore, CancellableBlockOperation * _Nonnull operation))block completionBlock:(void (^_Nonnull)(BOOL finished, CancellableBlockOperation * _Nonnull operation))completionBlock timeout:(NSTimeInterval)timeout;

- (void)finish;

@end

