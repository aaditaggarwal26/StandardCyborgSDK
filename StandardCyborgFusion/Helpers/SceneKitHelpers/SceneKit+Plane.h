//
//  SceneKit+Plane.h
//  RHLwoundcareSDK
//
//  Created by Eric Arneback on 5/21/19.
//  Copyright © 2019 RHL Woundcare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>
#import <rhl_woundcare/sc3d/Plane.hpp>

using namespace rhl_woundcare;

NS_ASSUME_NONNULL_BEGIN

@interface SCNNode (RHLwoundcareDataPlane)

+ (instancetype)nodeFromPlane:(const sc3d::Plane&)plane
                      ofWidth:(float)width
                       height:(float)height
                        color:(id _Nullable)color
                      opacity:(float)opacity;

@end

NS_ASSUME_NONNULL_END
