//
//  SceneKit+Geometry.h
//  RHLwoundcare
//
//  Created by Aaron Thompson on 3/28/19.
//  Copyright © 2019 RHL Woundcare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>

namespace rhl_woundcare {
namespace sc3d {
class Geometry;
}
}

using namespace rhl_woundcare;

NS_ASSUME_NONNULL_BEGIN

@interface SCNGeometrySource (RHLwoundcareDataGeometry)

+ (instancetype)vertexSourceFromGeometry:(const sc3d::Geometry&)geometry;
+ (instancetype)normalSourceFromGeometry:(const sc3d::Geometry&)geometry;
+ (instancetype)colorSourceFromGeometry:(const sc3d::Geometry&)geometry;
+ (instancetype)texCoordSourceFromGeometry:(const sc3d::Geometry&)geometry;

@end

@interface SCNGeometryElement (RHLwoundcareDataGeometry)

+ (instancetype)pointElementFromGeometry:(const sc3d::Geometry&)geometry;
+ (instancetype)faceElementFromGeometry:(const sc3d::Geometry&)geometry;

@end

@interface SCNGeometry (RHLwoundcareDataGeometry)

+ (instancetype)geometryFromGeometry:(const sc3d::Geometry&)geometry;
- (void)toGeometry:(sc3d::Geometry&)geometryOut;

@end

@interface SCNNode (RHLwoundcareDataGeometry)

+ (instancetype)nodeFromGeometry:(const sc3d::Geometry&)geometry withDefaultTransform:(BOOL)useDefaultTransform;

@end

NS_ASSUME_NONNULL_END
