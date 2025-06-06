//
//  ComputeNormalsKernel.h
//  RHLwoundcare
//
//  Created by Aaron Thompson on 8/2/18.
//  Copyright © 2018 RHL Woundcare. All rights reserved.
//

#import <Metal/Metal.h>
#import <RHLwoundcare/ProcessedFrame.hpp>
#import <rhl_woundcare/sc3d/PerspectiveCamera.hpp>
#import "MetalComputeEngine.h"

using namespace rhl_woundcare;

NS_ASSUME_NONNULL_BEGIN

@interface ComputeNormalsKernel : NSObject <MetalComputeKernel>

- (instancetype)initWithDevice:(id<MTLDevice>)device
                       library:(id<MTLLibrary>)library;

- (void)setPerspectiveCamera:(const sc3d::PerspectiveCamera&)camera
                  frameWidth:(size_t)width
                 frameHeight:(size_t)height;

@end

NS_ASSUME_NONNULL_END
