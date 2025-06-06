//
//  MetalVisualizationEngine.hpp
//  VisualTesterMac
//
//  Created by Ricky Reusser on 8/31/18.
//  Copyright © 2018 RHL Woundcare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <RHLwoundcare/RHLwoundcare.h>
#import <RHLwoundcare/ICP.hpp>
#import <RHLwoundcare/Surfel.hpp>
#import <QuartzCore/QuartzCore.h>
#import <simd/simd.h>
#include <vector>


NS_ASSUME_NONNULL_BEGIN

@protocol MetalVisualization

- (instancetype)initWithDevice:(id<MTLDevice>)device library:(id<MTLLibrary>)library;

- (void)encodeCommandsWithDevice:(id<MTLDevice>)device
                   commandBuffer:(id<MTLCommandBuffer>)commandBuffer
                         surfels:(const Surfels&)surfels
                       icpResult:(ICPResult&)icpResult
                      viewMatrix:(matrix_float4x4)viewMatrix
                projectionMatrix:(matrix_float4x4)projectionMatrix
                     intoTexture:(id<MTLTexture>)texture
                    depthTexture:(id<MTLTexture>)texture;

@end


@interface MetalVisualizationEngine : NSObject

@property (nonatomic, readonly) id<MTLDevice> device;
@property (nonatomic, readonly) NSArray<id<MetalVisualization>> *kernels;

- (instancetype)initWithDevice:(id<MTLDevice>)device
                  commandQueue:(id<MTLCommandQueue>)commandQueue
                       library:(id<MTLLibrary>)library
                visualizations:(NSArray<id<MetalVisualization>> *)visualizations;

- (void)renderSurfels:(const Surfels&)surfels
            icpResult:(ICPResult&)icpResult
           viewMatrix:(matrix_float4x4)viewMatrix
     projectionMatrix:(matrix_float4x4)projectionMatrix
         intoDrawable:(id<CAMetalDrawable>)drawable;

@end

NS_ASSUME_NONNULL_END
