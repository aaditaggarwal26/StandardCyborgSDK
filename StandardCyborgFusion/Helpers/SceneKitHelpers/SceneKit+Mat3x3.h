//
//  SceneKit+Mat3x3.h
//  RHLwoundcareSDK
//
//  Created by Eric Arneback on 5/21/19.
//  Copyright © 2019 RHL Woundcare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>
#import <rhl_woundcare/math/Mat3x3.hpp>

NS_ASSUME_NONNULL_BEGIN

@interface SCNNode (RHLwoundcareDataMat3x3)

+ (instancetype)nodeFromMat3x3:(const rhl_woundcare::math::Mat3x3&)mat withScale:(float)scale;

@end

NS_ASSUME_NONNULL_END
