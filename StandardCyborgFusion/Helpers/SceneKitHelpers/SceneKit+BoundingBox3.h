//
//  SceneKit+BoundingBox3.h
//  RHLwoundcareSDK
//
//  Created by Eric Arneback on 5/21/19.
//  Copyright © 2019 RHL Woundcare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>
#import <rhl_woundcare/sc3d/BoundingBox3.hpp>

NS_ASSUME_NONNULL_BEGIN

@interface SCNNode (RHLwoundcareDataBoundingBox3)

+ (instancetype)nodeFromBoundingBox3:(const rhl_woundcare::sc3d::BoundingBox3&)boundingBox;

@end

NS_ASSUME_NONNULL_END
