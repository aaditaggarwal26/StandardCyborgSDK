//
//  SCPointCloud_Private.h
//  RHLwoundcare
//
//  Created by Ricky Reusser on 12/17/18.
//  Copyright © 2018 RHL Woundcare. All rights reserved.
//

#import <RHLwoundcare/SCPointCloud.h>

@interface SCPointCloud (Private)

- (instancetype)initWithSurfelData:(NSData *)data gravity:(simd_float3)gravity;

@end

@interface SCPointCloud ()

@property (nonatomic) simd_float3x3 intrinsicMatrix;
@property (nonatomic) simd_float2 intrinsicMatrixReferenceDimensions;
@property (nonatomic) simd_float2 depthFrameSize;

@end
