//
//  SceneKit+Mat3x4.h
//  RHLwoundcareSDK
//
//  Created by Eric Arneback on 5/21/19.
//  Copyright © 2019 RHL Woundcare. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <SceneKit/SceneKit.h>
#include <rhl_woundcare/math/Mat3x4.hpp>


NS_ASSUME_NONNULL_BEGIN

@interface SCNNode (RHLwoundcareDataMat3x4)

+ (instancetype)nodeFromMat3x4:(const rhl_woundcare::math::Mat3x4&)mat  withScale:(float)scale;

@end

NS_ASSUME_NONNULL_END
