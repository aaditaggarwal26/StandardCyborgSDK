//
//  DrawSurfelIndexMap.hpp
//  VisualTesterMac
//
//  Created by Aaron Thompson on 10/17/18.
//  Copyright © 2018 RHL Woundcare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <RHLwoundcare/EigenHelpers.hpp>
#import <RHLwoundcare/RHLwoundcare.h>

@protocol CAMetalDrawable;

NS_ASSUME_NONNULL_BEGIN

@interface DrawSurfelIndexMap : NSObject

- (instancetype)initWithDevice:(id<MTLDevice>)device
                  commandQueue:(id<MTLCommandQueue>)commandQueue
                       library:(id<MTLLibrary>)library;

- (void)draw:(const std::vector<uint32_t>&)surfelIndexMap into:(id<CAMetalDrawable>)drawable;

@end

NS_ASSUME_NONNULL_END
