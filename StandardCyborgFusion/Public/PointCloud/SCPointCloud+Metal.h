//
//  SCPointCloud+Metal.h
//  RHLwoundcare
//
//  Copyright © 2018 RHL Woundcare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <RHLwoundcare/SCPointCloud.h>
#import <Metal/Metal.h>

NS_ASSUME_NONNULL_BEGIN

@interface SCPointCloud (Metal)

- (id<MTLBuffer>)buildPointsMTLBufferWithDevice:(id<MTLDevice>)device;

+ (MTLVertexFormat)positionMTLVertexFormat;
+ (MTLVertexFormat)normalMTLVertexFormat;
+ (MTLVertexFormat)colorMTLVertexFormat;
+ (MTLVertexFormat)weightMTLVertexFormat;

@end

NS_ASSUME_NONNULL_END
