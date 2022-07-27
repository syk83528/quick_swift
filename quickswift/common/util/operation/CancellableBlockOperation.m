//
//  CancellableBlockOperation.m
//  spsd
//
//  Created by Wildog on 1/4/20.
//  Copyright © 2020 Wildog. All rights reserved.
//

#import "CancellableBlockOperation.h"
#import <UIKit/UIKit.h>

@interface CancellableBlockOperation ()

@property (nonatomic, copy, nullable) void (^finalBlock)(BOOL finished, CancellableBlockOperation * _Nonnull operation);

/// <#注释#>
@property (nonatomic, assign) UIBackgroundTaskIdentifier tempTaskIdentifier;

@end

@implementation CancellableBlockOperation

+ (instancetype _Nonnull)operationWithBlock:(void (^_Nonnull)(dispatch_semaphore_t _Nullable semaphore, CancellableBlockOperation * _Nonnull operation))block timeout:(NSTimeInterval)timeout {
    CancellableBlockOperation *operation = [[CancellableBlockOperation alloc] init];
    operation.block = block;
    operation.timeout = timeout;
    return operation;
}

+ (instancetype _Nonnull)operationWithBlock:(void (^_Nonnull)(dispatch_semaphore_t _Nullable semaphore, CancellableBlockOperation * _Nonnull operation))block completionBlock:(void (^_Nonnull)(BOOL finished, CancellableBlockOperation * _Nonnull operation))completionBlock timeout:(NSTimeInterval)timeout {
    CancellableBlockOperation *operation = [[CancellableBlockOperation alloc] init];
    operation.block = block;
    operation.timeout = timeout;
    operation.finalBlock = completionBlock;
    return operation;
}

- (void)main {
    @autoreleasepool {
        if (!self.block) {
            return;
        }
        if (self.cancelled) {
            self.block = nil;
            self.finalBlock = nil;
            self.context = nil;
            return;
        }
        BOOL keepRunningInBackground = self.keepRunningInBackground;
        self.tempTaskIdentifier = UIBackgroundTaskInvalid;
        if (keepRunningInBackground) {
            self.tempTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
                [[UIApplication sharedApplication] endBackgroundTask:self.tempTaskIdentifier];
                self.tempTaskIdentifier = UIBackgroundTaskInvalid;
            }];
        }
        self.semaphore = dispatch_semaphore_create(0);
        self.block(self.semaphore, self);
        dispatch_semaphore_wait(self.semaphore, self.timeout > 0 ? dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.timeout * NSEC_PER_SEC)) : DISPATCH_TIME_FOREVER);
        self.block = nil;
        if (self.finalBlock) {
            self.finalBlock(!self.__cancelled, self);
        }
        self.finalBlock = nil;
        self.context = nil;
        [self endBackgroundTask];
    }
}

- (void)endBackgroundTask {
    if (self.tempTaskIdentifier != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:self.tempTaskIdentifier];
        self.tempTaskIdentifier = UIBackgroundTaskInvalid;
    }
}

- (void)finish {
    if (self.semaphore) {
        dispatch_semaphore_signal(self.semaphore);
    }
    [self endBackgroundTask];
    [super cancel];
}

- (void)cancel {
    self.__cancelled = YES;
    [self finish];
}

@end
