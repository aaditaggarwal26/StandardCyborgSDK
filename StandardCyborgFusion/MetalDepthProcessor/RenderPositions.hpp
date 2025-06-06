//
//  RenderPositions.hpp
//  VisualTesterMac
//
//  Created by Eric on 8/31/18.
//  Copyright © 2018 RHL Woundcare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Metal/Metal.h>
#import <rhl_woundcare/sc3d/Geometry.hpp>

using namespace rhl_woundcare;

@interface RenderPositions : NSObject

- (instancetype)initWithDevice:(id<MTLDevice>)device
                       library:(id<MTLLibrary>)library;

- (void)encodeCommandsWithDevice:(id<MTLDevice>)device
                   commandBuffer:(id<MTLCommandBuffer>)commandBuffer
                    triangleMesh:(const sc3d::Geometry&)triangleMesh
                     intoTexture:(id<MTLTexture>)texture;

@end
