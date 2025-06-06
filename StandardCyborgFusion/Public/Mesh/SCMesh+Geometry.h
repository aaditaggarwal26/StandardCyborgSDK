//
//  SCMesh+Geometry.h
//  RHLwoundcare
//
//  Created by Aaron Thompson on 10/17/19.
//  Copyright © 2019 RHL Woundcare. All rights reserved.
//

#ifdef __cplusplus

#import <Foundation/Foundation.h>
#import <rhl_woundcare/sc3d/Geometry.hpp>
#import <RHLwoundcare/SCMesh.h>

NS_ASSUME_NONNULL_BEGIN

using namespace rhl_woundcare;

@interface SCMesh (RHLwoundcareGeometry)

+ (SCMesh * _Nullable)meshWithVertexColorsFromGeometry:(const sc3d::Geometry &)geometry;

+ (SCMesh * _Nullable)meshFromGeometry:(const sc3d::Geometry &)geometry
                           textureData:(const std::vector<float> &)textureData
                     textureResolution:(NSInteger)textureResolution;

+ (SCMesh * _Nullable)meshFromGeometry:(const sc3d::Geometry &)geometry
                       textureJPEGPath:(NSString *)JPEGPath;

- (void)toGeometry:(sc3d::Geometry &)geo;

@end

NS_ASSUME_NONNULL_END

#endif // __cplusplus
